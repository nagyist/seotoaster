<?php

class LoginController extends Zend_Controller_Action {

    public function init() {
		$this->view->websiteUrl = $this->_helper->website->getUrl();
    }

    public function indexAction() {
		$this->_helper->page->doCanonicalRedirect('go');

        $xmlHttpRequest = $this->_request->isXmlHttpRequest();
		//if logged in user trys to go to the login page - redirect him to the main page
		if(Tools_Security_Acl::isAllowed(Tools_Security_Acl::RESOURCE_PAGE_PROTECTED)) {
            if ($xmlHttpRequest === true) {
                $this->_helper->response->fail(array('redirect' => $this->_helper->website->getUrl()));
            } else {
                $this->_redirect($this->_helper->website->getUrl());
            }
		}

        $loginForm = new Application_Form_Login();
		$secureToken = Tools_System_Tools::initSecureToken(Tools_System_Tools::ACTION_PREFIX_LOGIN);
		$this->view->secureToken = $secureToken;

		if($this->getRequest()->isPost()) {
			$secureToken = $this->_request->getParam(Tools_System_Tools::CSRF_SECURE_TOKEN, false);
			$tokenValid = Tools_System_Tools::validateToken($secureToken, Tools_System_Tools::ACTION_PREFIX_LOGIN);
			if (!$tokenValid) {
			    if ($xmlHttpRequest === true) {
                    $this->_helper->response->fail(array('message' => $this->_helper->language->translate('Wrong token')));
                } else {
                    $this->_checkRedirect(false, array());
                }

			}
			$loginForm->removeElement(Tools_System_Tools::CSRF_SECURE_TOKEN);

			//code verification part start section
			if (isset($this->_helper->session->verificationCodeUserId)) {
                $loginVerificationCode = $this->_request->getParam('login-verification-code', FILTER_SANITIZE_NUMBER_INT);
                $isVerificationCodeValid = Tools_System_MfaTools::isVerificationCodeValid($this->_helper->session->verificationCodeUserId, $loginVerificationCode);
                if ($isVerificationCodeValid === false) {
                    Tools_System_MfaTools::cleanVerificationUserId();
                    if (!isset($this->_helper->session->verificationCodeUserId)) {
                        if ($xmlHttpRequest === true) {
                            $this->_helper->response->fail(array('refresh' => '1', 'message' => $this->_helper->language->translate('Verification code has been expired. Please re-login.')));
                        } else {
                            $this->_checkRedirect(false, array('email' => $this->_helper->language->translate('Verification code has been expired. Please re-login.')));
                        }
                    } else {
                        if ($xmlHttpRequest === true) {
                            $this->_helper->response->fail(array('message' => $this->_helper->language->translate('Please enter valid verification code')));
                        } else {
                            $this->_checkRedirect(false, array('email' => $this->_helper->language->translate('Please enter valid verification code')));
                        }
                    }
                }

                $userMapper = Application_Model_Mappers_UserMapper::getInstance();
                $userModel = $userMapper->find($this->_helper->session->verificationCodeUserId);
                if (!$userModel instanceof Application_Model_Models_User) {
                    if ($xmlHttpRequest === true) {
                        $this->_helper->response->fail(array('message' => $this->_helper->language->translate('User not found')));
                    } else {
                        $this->_checkRedirect(false, array('email' => $this->_helper->language->translate('User not found')));
                    }
                }

                $userModel->setPassword('');
                $userModel->setLastLogin(date(Tools_System_Tools::DATE_MYSQL));
                $userModel->setIpaddress($_SERVER['REMOTE_ADDR']);
                $this->_helper->session->setCurrentUser($userModel);
                $userMapper->save($userModel);
                Zend_Session::regenerateId();
                $cacheHelper = Zend_Controller_Action_HelperBroker::getStaticHelper('cache');
                $cacheHelper->clean();
                unset($this->_helper->session->verificationCodeUserId);
                unset($this->_helper->session->verificationCodeUserIdExpiresAt);

                if($userModel->getRoleId() == Tools_Security_Acl::ROLE_MEMBER) {
                    $this->_memberRedirect();
                }

                if($userModel->getRoleId() == Tools_Security_Acl::ROLE_SUPERADMIN) {
                    $superAdminRedirectPageModel = Application_Model_Mappers_PageMapper::getInstance()->fetchByOption('option_adminredirect', true);
                    if ($superAdminRedirectPageModel instanceof Application_Model_Models_Page) {
                        if ($xmlHttpRequest === true) {
                            $this->_helper->response->fail(array('redirect' => $this->_helper->website->getUrl() . $superAdminRedirectPageModel->getUrl()));
                        } else {
                            $this->_redirect($this->_helper->website->getUrl() . $superAdminRedirectPageModel->getUrl(), array('exit' => true));
                        }
                    }
                }

                if (Tools_Security_Acl::isAllowed(Tools_Security_Acl::RESOURCE_PLUGINS, $userModel->getRoleId())) {
                    $configHelper = Zend_Controller_Action_HelperBroker::getStaticHelper('config');
                    $redirectAdminAfterLogin = $configHelper->getConfig('redirectAdminAfterLogin');

                    if (!empty($redirectAdminAfterLogin)) {
                        $redirector = new Zend_Controller_Action_Helper_Redirector();
                        if ($xmlHttpRequest === true) {
                            $this->_helper->response->fail(array('redirect' => $this->_helper->website->getUrl() . $redirectAdminAfterLogin));
                        } else {
                            $redirector->gotoUrl($this->_helper->website->getUrl() . $redirectAdminAfterLogin);
                        }
                    }
                }
                //code verification part end section


                if(isset($this->_helper->session->redirectUserTo)) {
                    if ($xmlHttpRequest === true) {
                        $this->_helper->response->fail(array('redirect' => $this->_helper->website->getUrl() . $this->_helper->session->redirectUserTo));
                    } else {
                        $this->_redirect($this->_helper->website->getUrl() . $this->_helper->session->redirectUserTo, array('exit' => true));
                    }

                }
                if (isset($this->_helper->session->loginCustomRedirect)) {
                    $customRedirect = $this->_helper->session->loginCustomRedirect;
                    unset($this->_helper->session->loginCustomRedirect);
                    if ($xmlHttpRequest === true) {
                        $this->_helper->response->fail(array('redirect' => $customRedirect));
                    } else {
                        $this->redirect($customRedirect, array('exit' => true));
                    }
                }

                if ($xmlHttpRequest === true) {
                    $this->_helper->response->fail(array('redirect' => (isset($_SERVER['HTTP_REFERER'])) ? $_SERVER['HTTP_REFERER'] : $this->_helper->website->getUrl()));
                } else {
                    $this->_redirect((isset($_SERVER['HTTP_REFERER'])) ? $_SERVER['HTTP_REFERER'] : $this->_helper->website->getUrl());
                }
			}

			if($loginForm->isValid($this->getRequest()->getParams())) {
				$authAdapter = new Zend_Auth_Adapter_DbTable(
					Zend_Registry::get('dbAdapter'),
					'user',
					'email',
					'password',
					'MD5(?)'
				);
				$authAdapter->setIdentity($loginForm->getValue('email'));
				$authAdapter->setCredential($loginForm->getValue('password'));
				$authResult = $authAdapter->authenticate();
				if($authResult->isValid()) {
					$authUserData = $authAdapter->getResultRowObject(null, 'password');
					if(null !== $authUserData) {
                        $userInfo = (array)$authUserData;
                        $userRoleId = $userInfo['role_id'];
					    $ipAddress = Tools_System_Tools::getIpAddress();
                        if ($userRoleId === Tools_Security_Acl::ROLE_SUPERADMIN) {
                            $userWhitelistIpsMapper = Application_Model_Mappers_UserWhitelistIpsMapper::getInstance();
                            $ipWhiteListRecordsExists = $userWhitelistIpsMapper->checkIfRecordsExists();
                            if (!empty($ipWhiteListRecordsExists)) {
                                $userWhitelistIpModel = $userWhitelistIpsMapper->findWhiteListedIp($ipAddress, Tools_Security_Acl::ROLE_SUPERADMIN);
                                if (!$userWhitelistIpModel instanceof Application_Model_Models_UserWhitelistIp) {
                                    if ($xmlHttpRequest === true) {
                                        $this->_helper->response->fail(array('message' => $this->_helper->language->translate('Access not allowed')));
                                    } else {
                                        $this->_checkRedirect(false, array('email' => $this->_helper->language->translate('Access not allowed')));
                                    }
                                }
                            }
                        }

                        $userModel = Application_Model_Mappers_UserMapper::getInstance()->findByEmail($loginForm->getValue('email'));
                        if (!$userModel instanceof Application_Model_Models_User) {
                            if ($xmlHttpRequest === true) {
                                $this->_helper->response->fail(array('message' => $this->_helper->language->translate('There is no user with such login and password.')));
                            } else {
                                $this->_checkRedirect(false, array('email' => $this->_helper->language->translate('There is no user with such login and password.')));
                            }
                        }

                        $userId = $userModel->getId();
                        if (Tools_System_MfaTools::isUserEligibleForMfa($userId) === true) {
//                            $signInType = $this->getRequest()->getParam('singintype');
//                            if (!empty($signInType) && $signInType == Tools_Security_Acl::ROLE_MEMBER) {
//                                if ($xmlHttpRequest === true) {
//                                    $this->_helper->response->fail(array('message' => $this->_helper->language->translate('Use') . ' <a target="_blank" href="' . $this->_helper->website->getUrl() . 'go"' . '>' . $this->_helper->website->getUrl() . 'go</a> ' . $this->_helper->language->translate('to be able to login into the website.')));
//                                } else {
//                                    $this->_checkRedirect(false, array('email' => $this->_helper->language->translate('Use') . ' <a target="_blank" href="' . $this->_helper->website->getUrl() . 'go"' . '>' . $this->_helper->website->getUrl() . 'go</a> ' . $this->_helper->language->translate('to be able to login into the website.')));
//                                }
//                            }

                            $mfaResponse = Tools_System_MfaTools::sendMfaNotification($userId);
                            if (empty($mfaResponse)) {
                                if ($xmlHttpRequest === true) {
                                    $this->_helper->response->fail(array('message' => $this->_helper->language->translate('There is no user with such login and password.')));
                                } else {
                                    $this->_checkRedirect(false, array('email' => $this->_helper->language->translate('There is no user with such login and password.')));
                                }
                            }

                            if (!empty($mfaResponse['error'])) {
                                if ($xmlHttpRequest === true) {
                                    $this->_helper->response->fail(array('message' => $mfaResponse['message']));
                                } else {
                                    $this->_checkRedirect(false, array('email' => $mfaResponse['message']));
                                }
                            }

                            $this->_helper->session->verificationCodeUserId = $userId;
                            $this->_helper->session->verificationCodeUserIdExpiresAt = Tools_System_Tools::convertDateFromTimezone('+10 minutes', 'UTC', 'UTC');

                            if ($xmlHttpRequest === true) {
                                $this->_helper->response->success(array('message' => $this->_helper->language->translate('Verification code was sent to your email.')));
                            } else {
                                $this->_checkRedirect(false, array('email' => $this->_helper->language->translate('Verification code was sent to your email.')));
                            }
                        }

						$user = new Application_Model_Models_User((array)$authUserData);
						$user->setLastLogin(date(Tools_System_Tools::DATE_MYSQL));
						$user->setIpaddress($ipAddress);
						$this->_helper->session->setCurrentUser($user);
						Application_Model_Mappers_UserMapper::getInstance()->save($user);
						unset($user);
						Zend_Session::regenerateId();
						$this->_helper->cache->clean();
						if($authUserData->role_id == Tools_Security_Acl::ROLE_MEMBER) {
							$this->_memberRedirect();
						}

                        if($authUserData->role_id == Tools_Security_Acl::ROLE_SUPERADMIN) {
                            $superAdminRedirectPageModel = Application_Model_Mappers_PageMapper::getInstance()->fetchByOption('option_adminredirect', true);
                            if ($superAdminRedirectPageModel instanceof Application_Model_Models_Page) {
                                if ($xmlHttpRequest === true) {
                                    $this->_helper->response->fail(array('redirect' => $this->_helper->website->getUrl() . $superAdminRedirectPageModel->getUrl()));
                                } else {
                                    $this->_redirect($this->_helper->website->getUrl() . $superAdminRedirectPageModel->getUrl(), array('exit' => true));
                                }
                            }
                        }

                        if (Tools_Security_Acl::isAllowed(Tools_Security_Acl::RESOURCE_PLUGINS, $authUserData->role_id)) {
                            $configHelper = Zend_Controller_Action_HelperBroker::getStaticHelper('config');
                            $redirectAdminAfterLogin = $configHelper->getConfig('redirectAdminAfterLogin');

                            if (!empty($redirectAdminAfterLogin)) {
                                $redirector = new Zend_Controller_Action_Helper_Redirector();
                                if ($xmlHttpRequest === true) {
                                    $this->_helper->response->fail(array('redirect' => $this->_helper->website->getUrl() . $redirectAdminAfterLogin));
                                } else {
                                    $redirector->gotoUrl($this->_helper->website->getUrl() . $redirectAdminAfterLogin);
                                }
                            }
                        }

						if(isset($this->_helper->session->redirectUserTo)) {
                            if ($xmlHttpRequest === true) {
                                $this->_helper->response->fail(array('redirect' => $this->_helper->website->getUrl() . $this->_helper->session->redirectUserTo));
                            } else {
                                $this->_redirect($this->_helper->website->getUrl() . $this->_helper->session->redirectUserTo, array('exit' => true));
                            }
						}
                        if (isset($this->_helper->session->loginCustomRedirect)) {
                            $customRedirect = $this->_helper->session->loginCustomRedirect;
                            unset($this->_helper->session->loginCustomRedirect);
                            if ($xmlHttpRequest === true) {
                                $this->_helper->response->fail(array('redirect' => $customRedirect));
                            } else {
                                $this->redirect($customRedirect, array('exit' => true));
                            }
                        }
                        if ($xmlHttpRequest === true) {
                            $this->_helper->response->fail(array('redirect' => (isset($_SERVER['HTTP_REFERER'])) ? $_SERVER['HTTP_REFERER'] : $this->_helper->website->getUrl()));
                        } else {
                            $this->_redirect((isset($_SERVER['HTTP_REFERER'])) ? $_SERVER['HTTP_REFERER'] : $this->_helper->website->getUrl());
                        }

					}
				}

				$signInType = $this->getRequest()->getParam('singintype');
				if($signInType && $signInType == Tools_Security_Acl::ROLE_MEMBER) {
					$this->_memberRedirect(false);
				}

                if ($xmlHttpRequest === true) {
                    $this->_helper->response->fail(array('message' => $this->_helper->language->translate('There is no user with such login and password.')));
                } else {
                    $this->_checkRedirect(false, array('email' => $this->_helper->language->translate('There is no user with such login and password.')));
                }
			}
			else {
                if ($xmlHttpRequest === true) {
                    $this->_helper->response->fail(array('message' => $this->_helper->language->translate('Login should be a valid email address')));
                } else {
                    $this->_checkRedirect(false, array('email' => $this->_helper->language->translate('Login should be a valid email address')));
                }
			}
		}
		else {
			//getting available system translations
            $this->view->languages = $this->_helper->language->getLanguages();
			$this->view->currentLanguage = strtolower(Zend_Registry::get('Zend_Locale')->getRegion());
            $locale               = Zend_Locale::getLocaleToTerritory(strtolower(Zend_Registry::get('Zend_Locale')->getRegion()));
            $this->view->htmlLang = substr($locale, 0, strpos($locale, '_'));
			//getting messages
            $errorMessages = $this->_helper->flashMessenger->getMessages();
            if (!empty($errorMessages)) {
                foreach ($errorMessages as $message) {
                    foreach ($message as $elementName => $msg) {
                        $loginForm->getElement($elementName)->setAttribs(array('class' => 'notvalid'));
                    }
                }
            }

            Tools_System_MfaTools::cleanVerificationUserId();
            $verificationCodeSection = false;
            if (isset($this->_helper->session->verificationCodeUserId)) {
                $verificationCodeSection = true;
                if (empty($errorMessages)) {
                    $errorMessages[] = array('email' => $this->_helper->language->translate('Verification code was sent to your email.'));
                }
            }

            $this->view->verificationCodeSection = $verificationCodeSection;

			$this->view->messages   = $errorMessages;
			//unset url redirect set from any login widget
			unset($this->_helper->session->redirectUserTo);
            $loginForm->removeDecorator('HtmlTag');
            $loginForm->setElementDecorators(array(
                    'ViewHelper',
                    'Errors',
                    'Label',
                    array('HtmlTag', array('tag' => 'p'))
            ));
            $this->view->loginForm  = $loginForm;
		}
	}

	public function logoutAction() {
		$this->_helper->getHelper('layout')->disableLayout();
		$this->_helper->viewRenderer->setNoRender(true);
		$this->_helper->session->getSession()->unsetAll();
		$this->_helper->cache->clean();
		$this->_checkRedirect($this->_helper->website->getUrl(), '');

	}

	private function _memberRedirect($success = true) {
        $xmlHttpRequest = $this->_request->isXmlHttpRequest();
        $landingPage = ($success) ? Tools_Page_Tools::getLandingPage(Application_Model_Models_Page::OPT_MEMLAND) : Tools_Page_Tools::getLandingPage(Application_Model_Models_Page::OPT_ERRLAND);
		if($landingPage instanceof Application_Model_Models_Page) {
            if ($xmlHttpRequest === true) {
                $this->_helper->response->fail(array('redirect' => $this->_helper->website->getUrl() . $landingPage->getUrl()));
            } else {
                $this->redirect($this->_helper->website->getUrl() . $landingPage->getUrl(), array('exit' => true));
            }
		}
	}

	private function _checkRedirect($url = '', $message = '') {
		if($message) {
			$this->_helper->flashMessenger->addMessage($message);
		}
		if(isset($_SERVER['HTTP_REFERER'])) {
			$this->_helper->redirector->gotoUrl($_SERVER['HTTP_REFERER'], array('exit' => true));
		}
		if(!$url) {
			$this->_helper->redirector->gotoRouteAndExit(array(
				'controller' => 'login',
				'action'     =>'index'
			));
		}
        $this->_helper->redirector->gotoUrlAndExit($url);
	}

	public function passwordretrieveAction() {
		$form = new Application_Form_PasswordRetrieve();
        $locale               = Zend_Locale::getLocaleToTerritory(strtolower(Zend_Registry::get('Zend_Locale')->getRegion()));
        $this->view->htmlLang = substr($locale, 0, strpos($locale, '_'));
		if($this->getRequest()->isPost()) {
			if($form->isValid($this->getRequest()->getParams())) {
				$retrieveData = $form->getValues();
				$user = Application_Model_Mappers_UserMapper::getInstance()->findByEmail(filter_var($retrieveData['email'], FILTER_SANITIZE_EMAIL));
				//create new reset token and send e-mail to the user
				$resetToken = Tools_System_Tools::saveResetToken($retrieveData['email'], $user->getId());
				if($resetToken instanceof Application_Model_Models_PasswordRecoveryToken) {
					$resetToken->registerObserver(new Tools_Mail_Watchdog(array(
						'trigger' => Tools_Mail_SystemMailWatchdog::TRIGGER_PASSWORDRESET
					)));
					$resetToken->notifyObservers();
					$this->_helper->flashMessenger->setNamespace('passreset')->addMessage($this->_helper->language->translate('We\'ve sent an email to')
						. ' ' . $user->getEmail() . ' ' .
						$this->_helper->language->translate('containing a temporary url that will allow you to reset your password for the next 24 hours. Please check your spam folder if the email doesn\'t appear within a few minutes.')
					);
                    if(isset($this->_helper->session->retrieveRedirect)){
                        $redirectTo = $this->_helper->session->retrieveRedirect;
                        unset($this->_helper->session->retrieveRedirect);
                        $this->redirect($this->_helper->website->getUrl() . $redirectTo);
                    }
                    $this->_helper->redirector->gotoRoute(array(
						'controller' => 'login',
						'action'     => 'passwordretrieve'
					));
				}
			} else {
				$messages       = array_values($form->getMessages());
				$flashMessanger = $this->_helper->flashMessenger;
				foreach($messages as $messageData) {
					if(is_array($messageData)) {
						array_walk($messageData, function($msg) use($flashMessanger) {
							$flashMessanger->addMessage(array('email' => $this->_helper->language->translate($msg)));
						});
					} else {
						$flashMessanger->addMessage(array('email' => $messageData));
					}
				}
				if(isset($this->_helper->session->retrieveRedirect)){
                    $redirectTo = $this->_helper->session->retrieveRedirect;
                    unset($this->_helper->session->retrieveRedirect);
                    return $this->redirect($this->_helper->website->getUrl() . $redirectTo);
                }
                return $this->redirect($this->_helper->website->getUrl() . 'login/retrieve/');
			}
		}
        $errorMessages = $this->_helper->flashMessenger->getMessages();
        if (!empty($errorMessages)) {
            foreach ($errorMessages as $message) {
                foreach ($message as $elementName => $msg) {
                    $form->getElement($elementName)->setAttribs(array('class' => 'notvalid'));
                }
            }
        }
        $passResetMsg = $this->_helper->flashMessenger->getMessages('passreset');
        if (!empty($passResetMsg)) {
            $this->view->retrieveSuccessMessage = join($passResetMsg, PHP_EOL);
        }

        $this->view->messages   = $this->_helper->flashMessenger->getMessages();

        $form->removeDecorator('HtmlTag');
        $form->setElementDecorators(array(
                'ViewHelper',
                'Errors',
                'Label',
                array('HtmlTag', array('tag' => 'p'))
        ));
		$this->view->form     = $form;
	}

	public function passwordresetAction() {
		//check the get string for the tokens http://mytoaster.com/login/reset/email/myemail@mytoaster.com/token/adadajqwek123klajdlkasdlkq2e3
		$error = false;
		$form  = new Application_Form_PasswordReset();
        $locale               = Zend_Locale::getLocaleToTerritory(strtolower(Zend_Registry::get('Zend_Locale')->getRegion()));
        $this->view->htmlLang = substr($locale, 0, strpos($locale, '_'));
		$email = filter_var($this->getRequest()->getParam('email', false), FILTER_SANITIZE_EMAIL);
		$token = filter_var($this->getRequest()->getParam('key', false), FILTER_SANITIZE_STRING);
		$newUser = filter_var($this->getRequest()->getParam('new', false), FILTER_SANITIZE_STRING);

		if(!$email || !$token) {
			$error = true;
		}
		$resetToken = Application_Model_Mappers_PasswordRecoveryMapper::getInstance()->findByTokenAndMail($token, $email);
		if(!$resetToken
			|| $resetToken->getStatus() != Application_Model_Models_PasswordRecoveryToken::STATUS_NEW
			|| $this->_isTokenExpired($resetToken)) {
				$error = true;
		}
		if($error) {
			$error = false;
			$this->_helper->flashMessenger->addMessage(array('email' => $this->_helper->language->translate('Token is incorrect. Please, enter your e-mail one more time.')));
			return $this->redirect($this->_helper->website->getUrl() . 'login/retrieve/');
		}

		if($this->getRequest()->isPost()) {
			if($form->isValid($this->getRequest()->getParams())) {
				$resetToken->registerObserver(new Tools_Mail_Watchdog(array(
                    'trigger' => Tools_Mail_SystemMailWatchdog::TRIGGER_PASSWORDCHANGE
				)));
				$resetData = $form->getValues();
				$mapper    = Application_Model_Mappers_UserMapper::getInstance();
				$user      = $mapper->find($resetToken->getUserId());
				$user->setPassword($resetData['password']);
				$mapper->save($user);
				$resetToken->setStatus(Application_Model_Models_PasswordRecoveryToken::STATUS_USED);
				Application_Model_Mappers_PasswordRecoveryMapper::getInstance()->save($resetToken);
				//$this->_helper->flashMessenger->addMessage($this->_helper->language->translate('Your password was reset.'));
                $roleId = $user->getRoleId();
                if($roleId != Tools_Security_Acl::ROLE_ADMIN && $roleId != Tools_Security_Acl::ROLE_SUPERADMIN){
                    return $this->redirect($this->_helper->website->getUrl());
                }
				return $this->redirect($this->_helper->website->getUrl() . 'go');
			} else {
				$this->_helper->flashMessenger->addMessage($this->_helper->language->translate('Passwords should match'));
				return $this->redirect($resetToken->getResetUrl());
			}
		}
		$this->view->messages = $this->_helper->flashMessenger->getMessages();
		$this->view->form = $form;
		$this->view->newUser = $newUser;
	}

	/**
	 * Check if the token is expired. If so change status and return true.
	 *
	 * @param Application_Model_Models_PasswordRecoveryToken $token
	 * @return bool
	 */
	private function _isTokenExpired(Application_Model_Models_PasswordRecoveryToken $token) {
		if(strtotime($token->getExpiredAt()) < time()) {
			$token->setStatus(Application_Model_Models_PasswordRecoveryToken::STATUS_EXPIRED);
			Application_Model_Mappers_PasswordRecoveryMapper::getInstance()->save($token);
			return true;
		}
		return false;
	}
}


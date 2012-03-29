<?php

class LoginController extends Zend_Controller_Action {

    public function init() {
		$this->view->websiteUrl = $this->_helper->website->getUrl();
    }

    public function indexAction() {
		$this->_helper->page->doCanonicalRedirect('go');
		//if logged in user trys to go to the login page - redirect him to the main page
		if(Tools_Security_Acl::isAllowed(Tools_Security_Acl::RESOURCE_PAGE_PROTECTED)) {
			$this->_redirect($this->_helper->website->getUrl());
		}

        $loginForm = new Application_Form_Login();
		if($this->getRequest()->isPost()) {
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
						$user = new Application_Model_Models_User();
						$user->setId($authUserData->id);
						$user->setEmail($authUserData->email);
						//$user->setPassword($authUserData->password);
						$user->setRoleId($authUserData->role_id);
						$user->setFullName($authUserData->full_name);
						$user->setLastLogin(date('Y-m-d H:i:s', time()));
						$user->setRegDate($authUserData->reg_date);
						$user->setIpaddress($_SERVER['REMOTE_ADDR']);
						$this->_helper->session->setCurrentUser($user);

						Application_Model_Mappers_UserMapper::getInstance()->save($user);

						unset($user);
						$this->_helper->cache->clean();

						if($authUserData->role_id == Tools_Security_Acl::ROLE_MEMBER) {
							$this->_memberRedirect();
						}

						if(isset($this->_helper->session->redirectUserTo)) {
							$this->_redirect($this->_helper->website->getUrl() . $this->_helper->session->redirectUserTo, array('exit' => true));
						}
						$this->_redirect((isset($_SERVER['HTTP_REFERER'])) ? $_SERVER['HTTP_REFERER'] : $this->_helper->website->getUrl());
					}
				}

				$signInType = $this->getRequest()->getParam('singintype');
				if($signInType && $signInType == Tools_Security_Acl::ROLE_MEMBER) {
					$this->_memberRedirect(false);
				}

				$this->_checkRedirect(false, 'There is no user with such login and password.');
			}
			else {
				$this->_checkRedirect(false, 'Login should be a valid email address');
			}
		}
		else {
			//getting available system translations
            $this->view->languages = $this->_helper->language->getLanguages();

			//getting messages
			$this->view->messages   = $this->_helper->flashMessenger->getMessages();

			//unset url redirect set from any login widget
			unset($this->_helper->session->redirectUserTo);

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
		$landingPage = ($success) ? Tools_Page_Tools::getLandingPage(Application_Model_Models_Page::OPT_MEMLAND) : Tools_Page_Tools::getLandingPage(Application_Model_Models_Page::OPT_ERRLAND);
		if($landingPage instanceof Application_Model_Models_Page) {
			$this->_redirect($this->_helper->website->getUrl() . $landingPage->getUrl(), array('exit' => true));
		}
	}

	private function _checkRedirect($url = '', $message = '') {
		if($message) {
			$this->_helper->flashMessenger->addMessage($message);
		}
		if(isset($_SERVER['HTTP_REFERER'])) {
			$this->_helper->session->errMemeberLogin = $this->_helper->flashMessenger->getMessages();
			$this->_helper->redirector->gotoUrl($_SERVER['HTTP_REFERER'], array('exit' => true));
		}
		if(!$url) {
			$this->_helper->redirector->gotoRoute(array(
				'controller' => 'login',
				'action'     =>'index'
			));
		}

	}
}


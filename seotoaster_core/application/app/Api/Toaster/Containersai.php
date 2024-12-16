<?php

class Api_Toaster_Containersai extends Api_Service_Abstract
{

    /**
     * System response helper
     *
     * @var null
     */
    protected $_responseHelper = null;

    /**
     * @var array Access Control List
     */
    protected $_accessList = array(
        Tools_Security_Acl::ROLE_SUPERADMIN => array(
            'allow' => array('get', 'post', 'put', 'delete')
        ),
        Tools_Security_Acl::ROLE_ADMIN => array(
            'allow' => array('get', 'post', 'put', 'delete')
        ),
        Tools_Security_Acl::ROLE_USER => array(
            'allow' => array('get', 'post', 'put', 'delete')
        )
    );


    public function init()
    {
        parent::init();
        $this->_responseHelper = Zend_Controller_Action_HelperBroker::getStaticHelper('response');
        $this->_configHelper = Zend_Controller_Action_HelperBroker::getStaticHelper('config');

    }


    /**
     *
     * Resource:
     * : /api/toaster/containersai/
     *
     * HttpMethod:
     * : GET
     *
     * @return JSON
     */
    public function getAction()
    {
        $this->postAction();
    }

    /**
     *
     * Resource:
     * : /api/toaster/containersai/
     *
     * HttpMethod:
     * : POST
     *
     * @return JSON
     */
    public function postAction()
    {
        $translator = Zend_Registry::get('Zend_Translate');

        $secureToken = $this->getRequest()->getParam(Tools_System_Tools::CSRF_SECURE_TOKEN, false);
        $tokenValid = Tools_System_Tools::validateToken($secureToken, Tools_System_Tools::ACTION_PREFIX_CONTAINERS);
        $websiteHelper = Zend_Controller_Action_HelperBroker::getStaticHelper('website');
        $websiteUrl = $websiteHelper->getUrl();
        if (!$tokenValid) {
            $this->_error($translator->translate('Your session has timed-out. Please Log back in ' . '<a href="' . $websiteUrl . 'go">here</a>'));
        }

        $sambaToken = $this->_configHelper->getConfig('sambaToken');
        $isRegistered = $this->_configHelper->getConfig('registered');
        if (empty($isRegistered) || empty($sambaToken)) {
            return array(
                'error' => '1',
                'message' => $translator->translate('Create your') . ' ' . '<a href="https://mojo.seosamba.com/register.html">' . $translator->translate('SeoSamba Free account') . '</a>'
            );
        }

        $content = $this->getRequest()->getParam('content');
        $wordCount = $this->getRequest()->getParam('wordCount');

        $info = array(
            'content' => $content,
            'wordCount' => $wordCount
        );

        $result = Apps::apiCall('POST', 'openaiContent', array(), $info);

        if (empty($result)) {
            return array(
                'error' => '1',
                'message' => $translator->translate('Service not available')
            );
        }

        if (!empty($result['error'])) {
            return array(
                'error' => '1',
                'message' => $result['message']
            );
        }

        if ($result['done'] === false) {
            return array(
                'error' => '1',
                'message' => $result['message']
            );
        }

        $data = json_decode($result['data'], true);

        $finalMessage = $data['overview'];

        return array(
            'error' => '0',
            'message' => $finalMessage
        );


    }

    /**
     *
     * Resource:
     *
     * HttpMethod:
     * : PUT
     *
     * ## Parameters:
     * id (source integer)
     *
     * @return JSON
     */
    public function putAction()
    {
    }

    /**
     *
     * Resource:
     *
     * HttpMethod:
     * : DELETE
     *
     * ## Parameters:
     * id (source integer)
     *
     * @return JSON
     */
    public function deleteAction()
    {

    }

}

<?php
/**
 * Header widget
 *
 * @author iamne
 */
class Widgets_Header_Header extends Widgets_AbstractContent {

	protected function  _init() {
		$this->_type    = (isset($this->_options[1]) && $this->_options[1] == 'static') ? Application_Model_Models_Container::TYPE_STATICHEADER : Application_Model_Models_Container::TYPE_REGULARHEADER;
		parent::_init();
	}

	protected function  _load() {
        $this->_container = $this->_find();
		$headerContent    = (null === $this->_container) ? '' : $this->_container->getContent();

        if(Tools_Security_Acl::isAllowed($this)) {
			if ((bool)Zend_Controller_Action_HelperBroker::getExistingHelper('config')->getConfig('inlineEditor') && !in_array('readonly',$this->_options)){
				$headerContent = '<div class="container-wrapper"><div class="header-editable">'.$headerContent.'</div>'.$this->_generateAdminControl(600, 140).'</div>';
			}else{
                $headerContent .= $this->_generateAdminControl(600, 140);
            }
		}
		return $headerContent;
	}

	/**
	 * Overrides abstract class method
	 * For Header and Content widgets we have a different resource id
	 *
	 * @return string ACL Resource id
	 */
	public function  getResourceId() {
		return Tools_Security_Acl::RESOURCE_CONTENT;
	}
}


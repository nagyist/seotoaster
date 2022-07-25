<?php

/**
 * Redirect form
 *
 * @author Eugene I. Nezhuta [Seotoaster Dev Team] <eugene@seotoaster.com>
 */
class Application_Form_Redirect extends Application_Form_Secure {

	protected $_fromUrl      = '';

	protected $_toUrl        = '';

	protected $_search        = '';

	protected $_toasterPages = array();


	public function init() {
        parent::init();
		$this->setMethod(Zend_Form::METHOD_POST)
			 ->setAttrib('class', '_fajax')
			 ->setAttrib('data-callback', 'reloadRedirectsList');

		$this->addElement(new Zend_Form_Element_Text(array(
			'id'         => 'from-url',
			'name'       => 'fromUrl',
            'attribs'    => array('autocomplete' => 'off'),
			'label'      => 'Former url',
			'value'      => $this->_fromUrl,
			'required'   => true,
			'validators' => array(
				new Validators_UrlRegex()
			),
			'filters'    => array(
				new Zend_Filter_StringTrim(),
				new Filters_UrlScheme()
			)
		)));

        $this->addElement(new Zend_Form_Element_Text(array(
            'id'         => 'redirect-search',
            'name'       => 'redirectSearch',
            'attribs'    => array('autocomplete' => 'off'),
            'label'      => 'Search',
            'value'      => $this->_search,
            'filters'    => array(
                new Zend_Filter_StringTrim()
            )
        )));

		$this->addElement(new Zend_Form_Element_Checkbox(array(
			'name'    => 'urlType',
			'required'  => true,
			'value'   => 'local',
			'checked' => 'checked'
		)));

		$this->addElement(new Zend_Form_Element_Select(array(
			'name'       => 'toUrl',
			'id'         => 'to-url',
			'value'      => $this->_toUrl,
			//'label'      => 'Url',
            'attribs'    => array('data-placeholder' => 'Select local url'),
			'class'      => '_tdropdown chosen-select',
			'filters'    => array(
				new Zend_Filter_StringTrim(),
				new Filters_UrlScheme()
			),
			'registerInArrayValidator' => false
		)));

        $this->getElement('toUrl')->setDisableTranslator(true);

		$this->addElement(new Zend_Form_Element_Button(array(
			'name'  => 'addRedirect',
			'id'    => 'add-redirect',
			'value' => 'Add redirect',
			'class' => 'btn ticon-plus grid_2 omega',
			'label' => 'Add redirect',
            'type'  => 'submit'
		)));

		$this->setElementDecorators(array('ViewHelper', 'Label'));

	}

	public function getFromUrl() {
		return $this->_fromUrl;
	}

	public function setFromUrl($fromUrl) {
		$this->_fromUrl = $fromUrl;
		$this->getElement('fromUrl')->setValue($fromUrl);
		return $this;
	}

    public function getSearch() {
        return $this->_search;
    }

    public function setSearch($search) {
        $this->_search = $search;
        $this->getElement('search')->setValue($search);
        return $this;
    }

	public function getToUrl() {
		return $this->_toUrl;
	}

	public function setToUrl($toUrl) {
		$this->_toUrl = $toUrl;
		$this->getElement('toUrl')->setValue($toUrl);
		return $this;
	}

	public function getToasterPages() {
		return $this->_toasterPages;
	}

	public function setToasterPages($toasterPages) {
		$this->_toasterPages = $toasterPages;
		$this->getElement('toUrl')->setMultioptions($toasterPages);
		return $this;
	}



}


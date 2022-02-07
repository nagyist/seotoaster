$(function(){
    var websiteUrl = $('#website_url').val(),
        toolbar2 = ' stw | styleselect | formatselect | fontsizeselect | pastetext visualblocks code removeformat | fullscreen |',// fontselect formatselect
        showMoreFlag = $('.show-more-content-widget').length;

    if(showMoreFlag){
        toolbar2 += ' | showMoreButton';
    }

    tinymce.init({
        selector : "textarea.tinymce",
        skin: 'oxide',//'seotoaster'
        width  : '100%',//'608px',
        height : '450px',
        menubar: false,
        resize: false,
        convert_urls: false,
        browser_spellcheck: true,
        relative_urls: false,
        statusbar: false,
        allow_script_urls: true,
        force_p_newlines: false,
        force_br_newlines : true,
        forced_root_block: '',
        remove_linebreaks : false,
        convert_newlines_to_br: true,
        entity_encoding: "raw",
        plugins: [
            "importcss advlist lists link anchor image charmap visualblocks code fullscreen media table paste hr quickbars stw"//textcolor moved to core
        ],
        toolbar1                : "bold italic underline alignleft aligncenter alignright alignjustify bullist numlist forecolor backcolor | link unlink anchor image media table hr |",
        toolbar2                : toolbar2,
        toolbar_sticky: true,
        link_list               : websiteUrl+'backend/backend_page/linkslist/',
        //content_css             : $('#reset_css').val()+','+$('#content_css').val(),
        content_css             : $('#content_css').val(),
        importcss_file_filter   : "content.css",
        importcss_append: true,
        importcss_selector_filter: /^(?!\.h1|\.h2|\.h3|\.h4|\.h5|\.h6|\.social-links*|\.callout*|\.callout*|\.panel*|.icon-*|\.icon12|\.icon14|\.icon16|\.icon18|\.icon24|\.icon32|\.icon48|\.toaster-icon|hr\.)/,
        importcss_groups : [
            {title : 'h1', filter : /^(h1\.)/},
            {title : 'h2', filter : /^(h2\.)/},
            {title : 'h3', filter : /^(h3\.)/},
            {title : 'h4', filter : /^(h4\.)/},
            {title : 'h5', filter : /^(h5\.)/},
            {title : 'h6', filter : /^(h6\.)/},
            {title : 'Button', filter : /^(\.btn.*|button\.)/},
            {title : 'Icons', filter : /^(\.no-icon|\.icon-.*)/},
            {title : 'Table', filter : /^(\.table.*|table\.)/},
            {title : 'List', filter : /^(\.list.*|ul\.|ol\.)/},
            {title : 'Image', filter : /^(\.image.*|\.img.*|img\.)/},
            {title : 'Blockquote', filter : /^(blockquote\.)/},
            {title : 'Separator', filter : /^(hr\.)/},
            {title : 'Message', filter : /^(\.message.*)/},
            {title : 'Badge', filter : /^(\.badge.*)/},
            {title : 'Color', filter : /^(\.primary|\.success|\.info|\.warning|\.error|\.green|\.blue|\.orange|\.red|\.gray-darker|\.gray-dark|\.gray|\.gray-light|\.gray-lighter|\..*color.*)$/},
            {title : 'Background', filter : /^(\..*-bg.*)/},      //new group
            {title : 'Size', filter : /^(\.larger|\.large|\.small|\.mini|\.size.*|\.fs.*)$/},
            {title : 'Text', filter : /^(\.uppercase|\.lowecase)$/},
            {title : 'Other styles'}
        ],
        importcss_merge_classes: true,
        //quickbars_selection_toolbar: 'bold italic | quicklink h2 h3 blockquote quickimage quicktable',
        quickbars_selection_toolbar: false,
        fontsize_formats        : "8px 10px 12px 14px 16px 18px 24px 36px",
        block_formats: "Block=div;Paragraph=p;Block Quote=blockquote;Address=address;Code=code;Preformatted=pre;H2=h2;H3=h3;H4=h4;H5=h5;H6=h6;",
        extended_valid_elements: "a[*],input[*],select[*],textarea[*]",
        image_advtab: true,
        setup : function(ed){
            var keyTime = null;
            ed.on('change blur keyup', function(ed, e){
                //@see content.js for this function
                self.dispatchEditorKeyup(ed, e, keyTime);
                this.save();
            });

            ed.ui.registry.addButton('showMoreButton', {
                title:'showMoreButton',
                text: 'Show more widget',
                onclick : function() {
                    if(showMoreFlag) {
                        var SHOWMORE = '#show-more#';
                        if (ed.getContent().indexOf(SHOWMORE) + 1) {
                            showMessage('Widget ' + SHOWMORE + ' already exists in content', false, 2000);
                        } else {
                            ed.focus();
                            ed.selection.setContent(SHOWMORE);
                        }
                    }
                }
            });
            ed.on('ExecCommand', function(editor, prop) {
                if (editor.command === 'mceInsertContent') {
                    if(typeof editor.value.content !== 'undefined') {
                        ed.selection.setContent('<span id="cursor-position-temp-span"/>');

                        var urlRegex = /(\b(https?):\/\/[\w\-]*)(?![^<>]*>(?:(?!<\/?a\b).)*<\/a>)/igu,
                            contentDomains = editor.value.content.match(urlRegex),
                            containerContent = tinymce.activeEditor.getContent();

                        if(contentDomains) {
                            var urlToLinkExp = /(\b(https?):\/\/[\w\/#=&;%\-?\.]*)((?![^<>]*>(?:(?!(<\/?a\b|<img\b)).)*))/igu;
                            containerContent = containerContent.replace(urlToLinkExp, function(url) {
                                return '<a href="' + url + '" target="_blank">' + url.replace(/(^\w+:|^)\/\//, '') + '</a>';
                            });

                            tinymce.activeEditor.setContent(containerContent);
                        }

                        var newNode = ed.dom.select('span#cursor-position-temp-span');
                        ed.selection.select(newNode[0]);
                        ed.selection.setContent('');
                    }
                }
            });
        }
    });

    /*tinymce.init({
        script_url              : websiteUrl+'system/js/external/tinymce/tinymce.gzip.php',
        selector                : "textarea.tinymce",
        skin                    : 'seotoaster',
        width                   : '100%',
        height                  : '350px',
        browser_spellcheck      : true,
        menubar                 : false,
        resize                  : false,
        convert_urls            : false,
        relative_urls           : false,
        statusbar               : false,
        allow_script_urls       : true,
        force_p_newlines        : true,
        forced_root_block       : false,
        entity_encoding         : "raw",
        content_css             : $('#reset_css').val()+','+$('#content_css').val(),
        importcss_file_filter   : "content.css",
        importcss_selector_filter: /^(?!\.h1|\.h2|\.h3|\.h4|\.h5|\.h6|\.social-links*|\.callout*|\.callout*|\.panel*|.icon-*|\.icon12|\.icon14|\.icon16|\.icon18|\.icon24|\.icon32|\.icon48|\.toaster-icon|hr\.)/,
        importcss_groups : [
            {title : 'h1', filter : /^(h1\.)/},
            {title : 'h2', filter : /^(h2\.)/},
            {title : 'h3', filter : /^(h3\.)/},
            {title : 'h4', filter : /^(h4\.)/},
            {title : 'h5', filter : /^(h5\.)/},
            {title : 'h6', filter : /^(h6\.)/},
            {title : 'Button', filter : /^(\.btn.*|button\.)/},
            {title : 'Icons', filter : /^(\.no-icon|\.icon-.*)/},
            {title : 'Table', filter : /^(\.table.*|table\.)/},
            {title : 'List', filter : /^(\.list.*|ul\.|ol\.)/},
            {title : 'Image', filter : /^(\.image.*|\.img.*|img\.)/},
            {title : 'Blockquote', filter : /^(blockquote\.)/},
            {title : 'Separator', filter : /^(hr\.)/},
            {title : 'Message', filter : /^(\.message.*)/},
            {title : 'Badge', filter : /^(\.badge.*)/},
            {title : 'Color', filter : /^(\.primary|\.success|\.info|\.warning|\.error|\.green|\.blue|\.orange|\.red|\.gray-darker|\.gray-dark|\.gray|\.gray-light|\.gray-lighter|\..*color.*)$/},
            {title : 'Background', filter : /^(\..*-bg.*)/},      //new group
            {title : 'Size', filter : /^(\.larger|\.large|\.small|\.mini|\.size.*|\.fs.*)$/},
            {title : 'Text', filter : /^(\.uppercase|\.lowecase)$/},
            {title : 'Other styles'}
        ],
        importcss_merge_classes: true,
        plugins                 : [
            "advlist lists link anchor image charmap visualblocks code fullscreen media table paste importcss textcolor stw"
        ],
        toolbar1                : "bold italic underline alignleft aligncenter alignright alignjustify | bullist numlist forecolor backcolor | link unlink anchor image media table hr",
        toolbar2                : toolbar2,
        fontsize_formats        : "8px 10px 12px 14px 16px 18px 24px 36px",
        block_formats           : "Block=div;Paragraph=p;Block Quote=blockquote;Cite=cite;Address=address;Code=code;Preformatted=pre;H2=h2;H3=h3;H4=h4;H5=h5;H6=h6",
        link_list               : websiteUrl+'backend/backend_page/linkslist/',
        image_advtab            : true,
        extended_valid_elements : "a[*],input[*],select[*],textarea[*]",
        setup                   : function(ed){
            var keyTime = null;
            ed.addButton('showMoreButton', {
                title:'showMoreButton',
                text: 'Show more widget',
                onclick : function() {
                    if(showMoreFlag) {
                        var SHOWMORE = '#show-more#';
                        if (ed.getContent().indexOf(SHOWMORE) + 1) {
                            showMessage('Widget ' + SHOWMORE + ' already exists in content', false, 2000);
                        } else {
                            ed.focus();
                            ed.selection.setContent(SHOWMORE);
                        }
                    }
                }
            });
            ed.on('ExecCommand', function(editor, prop) {
                if (editor.command === 'mceInsertContent') {
                    if(typeof editor.value.content !== 'undefined') {
                        ed.selection.setContent('<span id="cursor-position-temp-span"/>');

                        var urlRegex = /(\b(https?):\/\/[\w\-]*)(?![^<>]*>(?:(?!<\/?a\b).)*<\/a>)/igu,
                            contentDomains = editor.value.content.match(urlRegex),
                            containerContent = tinymce.activeEditor.getContent();

                        if(contentDomains) {
                            var urlToLinkExp = /(\b(https?):\/\/[\w\/#=&;%\-?\.]*)((?![^<>]*>(?:(?!(<\/?a\b|<img\b)).)*))/igu;
                            containerContent = containerContent.replace(urlToLinkExp, function(url) {
                                return '<a href="' + url + '" target="_blank">' + url.replace(/(^\w+:|^)\/\//, '') + '</a>';
                            });

                            tinymce.activeEditor.setContent(containerContent);
                        }

                        var newNode = ed.dom.select('span#cursor-position-temp-span');
                        ed.selection.select(newNode[0]);
                        ed.selection.setContent('');
                    }
                }
            });
            ed.on('change blur keyup', function(ed, e){
                //@see content.js for this function
                dispatchEditorKeyup(ed, e, keyTime);
                this.save();
            });
        }
    });*/
});

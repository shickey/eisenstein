(function () {

    /**
     * Window "onload" handler.
     * @return {void}
     */
    function onLoad () {
        // Instantiate the VM and create an empty project
        var vm = new window.VirtualMachine();
        window.vm = vm;
        
        //Load Empty Project
        var defaultProject = {
            "objName": "Stage",
            "sounds": [],
            "costumes": [],
            "currentCostumeIndex": 0,
            "variables": [],
            "children": []
        }
        vm.loadProject(defaultProject);

        // Get XML toolbox definition
        var toolbox = document.getElementById('toolbox');
        window.toolbox = toolbox;
        Blockly.VerticalFlyout.prototype.DEFAULT_WIDTH = 300;

        // Instantiate scratch-blocks and attach it to the DOM.
        var workspace = window.Blockly.inject('blocks', {
            media: './media/',
            scrollbars: false,
            trashcan: false,
            horizontalLayout: false,
            toolbox: window.toolbox,
            sounds: false,
            zoom: {
                controls: false,
                wheel: false,
                startScale: 1.0
            },
            colours: {
                workspace: '#334771',
                flyout: '#283856',
                scrollbar: '#24324D',
                scrollbarHover: '#0C111A',
                insertionMarker: '#FFFFFF',
                insertionMarkerOpacity: 0.3,
                fieldShadow: 'rgba(255, 255, 255, 0.3)',
                dragShadowOpacity: 0.6
            }
        });
        window.workspace = workspace;

        // Disable long-press
        Blockly.longStart_ = function() {};

        // Attach blocks to the VM
        workspace.addChangeListener(vm.blockListener);
        var flyoutWorkspace = workspace.getFlyout().getWorkspace();
        flyoutWorkspace.addChangeListener(vm.flyoutBlockListener);

        // Handle VM events
        vm.on('SCRIPT_GLOW_ON', function(data) {
            workspace.glowStack(data.id, true);
        });
        vm.on('SCRIPT_GLOW_OFF', function(data) {
            workspace.glowStack(data.id, false);
        });
        vm.on('BLOCK_GLOW_ON', function(data) {
            workspace.glowBlock(data.id, true);
        });
        vm.on('BLOCK_GLOW_OFF', function(data) {
            workspace.glowBlock(data.id, false);
        });
        vm.on('VISUAL_REPORT', function(data) {
            workspace.reportValue(data.id, data.value);
        });

        // Run threads
        vm.start();

        // DOM event handlers
        var greenFlag = document.querySelector('#greenflag');
        var stop = document.querySelector('#stop');

        greenFlag.addEventListener('click', function () {
            vm.greenFlag();
            // audio.stopAllSounds();
            // audio.clearEffects();
        });
        greenFlag.addEventListener('touchmove', function (e) {
            e.preventDefault();
        });
        stop.addEventListener('click', function () {
            vm.stopAll();
            // audio.stopAllSounds();
            // audio.clearEffects();
            if (typeof window.ext !== 'undefined') {
                window.ext.postMessage({
                    extension: 'video',
                    method: 'stopAll',
                    args: []
                });
            }
        });
        stop.addEventListener('touchmove', function (e) {
            e.preventDefault();
        });

        // Extension event handlers
        bindExtensionHandler();

    }

    // /**
    //  * Binds the extension interface to `window.ext`.
    //  * @return {void}
    //  */
    function bindExtensionHandler () {
        if (typeof webkit === 'undefined') return;
        if (typeof webkit.messageHandlers === 'undefined') return;
        if (typeof webkit.messageHandlers.ext === 'undefined') return;
        window.ext = webkit.messageHandlers.ext;

        // if (typeof webkit.messageHandlers.cons === 'undefined') return;
        window.cons = webkit.messageHandlers.cons;
        window.console.log = window.console.error = window.console.warn = window.console.info = (message) => {
            window.cons.postMessage({
                message: message
            });
        };

        console.log("hello from common!");
    }


    window.updateVideoMenus = function(videoInfo) {
        var menuItems = videoInfo.map((v, idx) => {
            return [v.title, idx.toString()];
        })

        window.Blockly.Blocks.video_videos_menu.init = function() {
            this.jsonInit({
                "message0": "%1",
                "args0": [
                    {
                        "type": "field_dropdown",
                        "name": "VIDEO_MENU",
                        "options": menuItems
                    }
                ],
                "colour": Blockly.Colours.more.secondary,
                "colourSecondary": Blockly.Colours.more.secondary,
                "colourTertiary": Blockly.Colours.more.tertiary,
                "extensions": ["output_string"]
            });
        }
        var tree = window.Blockly.getMainWorkspace().options.languageTree;
        window.Blockly.getMainWorkspace().updateToolbox(tree);
    }

    /**
     * Bind event handlers.
     */
    window.onload = onLoad;

})();

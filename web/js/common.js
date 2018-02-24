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
        Blockly.VerticalFlyout.prototype.DEFAULT_WIDTH = 302;

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
            // if (typeof window.ext !== 'undefined') {
            //     window.ext.postMessage({
            //         extension: 'wedo',
            //         method: 'motorStop',
            //         args: []
            //     });
            // }
        });
        stop.addEventListener('touchmove', function (e) {
            e.preventDefault();
        });

        // Extension event handlers
        bindExtensionHandler();

        // Audio engine
        // var audio = new AudioEngine();
        // window.audio = audio;
        // loadSoundsFromProject(135074076);
    }

    // /**
    //  * Load a project
    //  * @return {void}
    //  */
    // function loadProject(id) {
    //     var url = 'https://projects.scratch.mit.edu/internalapi/project/' +
    //         id + '/get/';
    //     var r = new XMLHttpRequest();
    //     r.onreadystatechange = function() {
    //         if (this.readyState === 4) {
    //             if (r.status === 200) {
    //                 window.vm.loadProject(this.responseText);
    //                 console.log(window.vm);
    //             } else {
    //                 window.vm.createEmptyProject();
    //             }
    //         }
    //     };
    //     r.open('GET', url);
    //     r.send();
    // };

    // /**
    //  * Binds the extension interface to `window.ext`.
    //  * @return {void}
    //  */
    function bindExtensionHandler () {
        if (typeof webkit === 'undefined') return;
        if (typeof webkit.messageHandlers === 'undefined') return;
        if (typeof webkit.messageHandlers.ext === 'undefined') return;
        window.ext = webkit.messageHandlers.ext;
    }

    // /**
    //  * Extension "connect" handler.
    //  * @return {void}
    //  */
    // function onConnect () {
    //     var di = document.querySelector('#navigation .device button');
    //     di.classList.add('connected');
    //     di.classList.remove('scanning');
    // }

    // /**
    //  * Extension "disconnect" handler.
    //  * @return {void}
    //  */
    // function onDisconnect () {
    //     var di = document.querySelector('#navigation .device button');
    //     di.classList.remove('connected');
    //     di.classList.remove('scanning');
    //     vm.stopAll();
    // }

    // /**
    //  * fetch the data from a project, but only load the sounds from the stage
    //  * update the sounds menu with the list of loaded sound names
    //  * @return {void}
    //  */
    // function loadSoundsFromProject(id) {
    //     var url = 'https://projects.scratch.mit.edu/internalapi/project/' +
    //         id + '/get/';
    //     var r = new XMLHttpRequest();
    //     r.onreadystatechange = function() {
    //         if (this.readyState === 4) {
    //             if (r.status === 200) {
    //                 var respObj = JSON.parse(this.responseText);
    //                 var sounds = respObj.sounds;

    //                 // populate objects containing metadata about sounds in the project
    //                 var soundObjs = [];
    //                 for (var i=0; i<sounds.length; i++) {
    //                     var soundObj = {};
    //                     soundObj.fileUrl = 'https://cdn.assets.scratch.mit.edu/internalapi/asset/'
    //                         + sounds[i].md5 + '/get/';
    //                     soundObj.name = sounds[i].soundName;
    //                     soundObj.format = sounds[i].format;
    //                     soundObjs.push(soundObj);
    //                 }
    //                 // load the sounds
    //                 window.audio.loadSounds(soundObjs);

    //                 // create menu items for blockly in the form [name, index]
    //                 // containing the names of the loaded sounds
    //                 var menuItems = [];
    //                 for (var i=0; i<soundObjs.length; i++) {
    //                     var item = [soundObjs[i].name, i.toString()];
    //                     menuItems.push(item);
    //                 }

    //                 // set the sound block's menu to the new menu
    //                 window.Blockly.Blocks.sound_sounds_menu.init = function() {
    //                     this.jsonInit(
    //                       {
    //                         "message0": "%1",
    //                         "args0": [
    //                           {
    //                             "type": "field_dropdown",
    //                             "name": "SOUND_MENU",
    //                             "options": menuItems
    //                           }
    //                         ],
    //                         "inputsInline": true,
    //                         "output": "String",
    //                         "colour": Blockly.Colours.sounds.secondary,
    //                         "colourSecondary": Blockly.Colours.sounds.secondary,
    //                         "colourTertiary": Blockly.Colours.sounds.tertiary,
    //                         "outputShape": Blockly.OUTPUT_SHAPE_ROUND
    //                       });
    //                 };
    //                 var tree = window.Blockly.getMainWorkspace().options.languageTree;
    //                 window.Blockly.getMainWorkspace().updateToolbox(tree);
    //             }
    //         }
    //     };
    //     r.open('GET', url);
    //     r.send();
    // };

    /**
     * Bind event handlers.
     */
    window.onload = onLoad;
    // window.onExtensionConnect = onConnect;
    // window.onExtensionDisconnect = onDisconnect;

})();

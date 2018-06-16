'use strict';

define([
    './BaseTask',
    'jquery'
  ],
  function (BaseTask) {
    /**
     * Select items task
     * - User is shown a series of text descriptions along with several items
     * - For each description, they are asked to select the correct items
     */
    function SelectItemTask(params) {
      BaseTask.call(this, params);

      this.nChoices = params.conf['nChoices'];
      this.nColumns = params.conf['nColumns'];
      this.defaultSource = params.conf['defaultSource'];
      this.imageUrlPattern = params.conf['imageUrlPattern'];
      this.allowPass = params.conf['allowPass'];
      this.__fixupEntries();

      this.descriptionElem = $(params.descriptionElem || '#description');
      this.itemsElem = $(params.itemsElem || '#items');
      if (this.allowPass) {
        this.passKey = 32; // Space
        this.passButton = $(params.descriptionElem || '#pass');
        this.passButton.click(this.select.bind(this, -1, true));
      }

      this.itemImageElems = [];
      this.itemImageFrameElems = [];
      for (var i = 0; i < this.nChoices; i++) {
        this.itemImageElems[i] = $('#itemImage' + i);
        this.itemImageFrameElems[i] = $('#itemImageFrame' + i);
        this.itemImageFrameElems[i].click(this.select.bind(this, i));
      }
      this.__bindShortcuts();
      this.selected = -1;
    }

    SelectItemTask.prototype = Object.create(BaseTask.prototype);
    SelectItemTask.prototype.constructor = SelectItemTask;

    // Bind shortcut keys
    SelectItemTask.prototype.__bindShortcuts = function() {
      var scope = this;
      $(document).keypress(function (e) {
        var keyCount = e.which - 49; // subtract ascii for "1" key number
        if (keyCount >= 0 && keyCount <= scope.nChoices) {
          var i = keyCount;
          scope.itemImageFrameElems[i].click();
          return false;
        } else if (e.which === scope.passKey) {
          scope.passButton.click();
          return false;
        }
      });
    };

    // Do some fixups to our entries
    SelectItemTask.prototype.__fixupEntries = function() {
      var source = this.defaultSource;
      function ensureSourceForId(id) {
        if (id.indexOf('.') >= 0) {
          return id;
        } else {
          return source + '.' + id;
        }
      }

      function ensureSource(item) {
        if (typeof item === 'string') {
          return ensureSourceForId(item);
        } else {
          item.id = ensureSourceForId(item.id);
          return item;
        }
      }

      if (this.defaultSource) {
        // Ensure all items have a source
        for (var i = 0; i < this.entries.length; i++) {
          var entry = this.entries[i];
          if (entry['items']) {
            entry['items'] = entry['items'].map(ensureSource);
          } else {
            for (var j = 0; j < this.nChoices; j++) {
              entry['item' + j] = ensureSource(entry['item' + j]);
            }
          }
        }
      }

      // Ensure items is array
      for (var i = 0; i < this.entries.length; i++) {
        var entry = this.entries[i];
        if (!entry['items']) {
          var items = [];
          for (var j = 0; j < this.nChoices; j++) {
            var item = this.__getItem(entry, j, { deleteKeys: true });
            items.push(item);
          }
          entry['items'] = items;
        }
        if (typeof entry['correctIndex'] === 'string') {
          entry['correctIndex'] = parseInt(entry['correctIndex']);
        }
      }
    };

    SelectItemTask.prototype.select = function (idx, save) {
      console.log("item " + idx + " selected");

      if (this.selected != idx) {
        if (this.selected >= 0) {
          this.itemImageFrameElems[this.selected].removeClass("selected");
        }
        this.selected = idx;
        if (idx >= 0) {
          this.itemImageFrameElems[idx].addClass("selected");
        }
      }

      if (save || (this.selected >= 0 && this.selected < this.nChoices)) {
        this.save();
      }
    };

    SelectItemTask.prototype.__getItem = function(entry, i, opts) {
      opts = opts || {};
      if (i < 0) return undefined;
      // Each entry can either have:
      //  items as array or separate fields item0, item1, item2,...
      var item = (entry['items'])? entry['items'][i] : entry['item' + i];
      if (typeof item === 'string') {
        // Just a id - need to populate it with url
        item = {
          id: item
        }
      }
      // get all keys starting with 'item' + i + '.'
      var prefix = 'item' + i + '.';
      var keys = Object.keys(entry).filter(function(k) { return k.startsWith(prefix); });
      for (var j = 0; j < keys.length; j++) {
        var k = keys[j];
        item[k.substring(prefix.length)] = entry[k];
        if (opts.deleteKeys) {
          delete entry[k];
        }
      }
      if (!item['url']) {
        item['url'] = this.getImageUrl(item.id);
      }
      return item;
    };

    SelectItemTask.prototype.getItem = function(entry, i) {
      // Assumes that items have been properly stuffed into an array
      if (i < 0) return undefined;
      var item = (entry['items'])? entry['items'][i] : undefined;
      return item;
    };

    SelectItemTask.prototype.check = function() {
      // TODO: Check if the description is acceptable...
      var ok = (this.selected >= 0 && this.selected < this.nChoices);
      var passed = this.allowPass && this.selected === -1;
      if (ok || passed){
        var currentEntry = this.entries[this.entryIndex];
        var correct = this.selected == currentEntry["correctIndex"];

        var results = {
          selectedIndex: this.selected,
          correct: correct,
          entry: currentEntry
        };
        var summary = {
          entryId: currentEntry.id,
          selectedIndex: this.selected,
          correct: correct
        };

        var selectedItem = this.getItem(currentEntry, this.selected);
        if (selectedItem) {
          results.selectedItemId = selectedItem.id;
          results.selectedItemUrl = selectedItem.url;
          summary.selectedItemId = selectedItem.id;
        }

        return {
          results: results,
          summary: summary
        }
      } else{
        return {
          error: "Please select a item!"
        };
      }
    };

    SelectItemTask.prototype.getImageUrl = function (fullId) {
      var parts = fullId.split('.');
      var source = parts[0];
      var itemId = parts[1];
      var url = this.imageUrlPattern.replaceAll('${id}', itemId);
      url = url.replaceAll('${source}', source);
      return url;
    };

    SelectItemTask.prototype.updateEntry = function(entry) {
      this.descriptionElem.text(entry['text']);
      for (var i = 0; i < this.nChoices; i++) {
        var item = this.getItem(entry, i);
        this.itemImageElems[i].attr('src', item.url);
      }
      this.select(-1);
    };

    SelectItemTask.prototype.__resizeImages = function(parent) {
      var itemImages = $(parent).find('.itemImage');
      var rowWidth = parent.width() || $(window).width();
      var nCols = this.nColumns || this.nChoices;
      var maxWidth = rowWidth / nCols - 70;  // Some padding
      itemImages.attr('width', maxWidth);
    };

    SelectItemTask.prototype.onResize = function() {
      this.__resizeImages(this.itemsElem);
      this.__resizeImages($('.mturkExample'));
    };

    // Exports
    return SelectItemTask;
  });

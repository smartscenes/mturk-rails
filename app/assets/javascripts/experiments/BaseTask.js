'use strict';

define([
  './PubSub',
  'bootbox',
  'jquery'
],
  function (PubSub, bootbox)
  {
    /**
     * Basic task
     * - User is show a series of items and asked to do something
     * - Override the following:
     *    check() return { result: <object to report>, summary: <object to stuff into summary>, error: "error message" };
     *    updateEntry(entry)
     */
    function BaseTask(params)
    {
      PubSub.call(this, params);
      this.entryIndex = 0;

      // Initialize from parameters
      // Some app
      // List of entries (i.e. scenes)
      // The url of where to load the scene from is specified in the 'url' field of each entry
      this.entries = params.entries;
      // Experiment condition
      this.condition = params.conf['condition'];
      this.base_url = params.base_url;

      // Summary to post for the overall task
      this.summary = [];
      // TODO: Be flexible about binding actions to buttons...
      this.taskInstructions = $('#taskInstructions');
      this.mturkOverlay = $('#mturkOverlay');
      this.startButton = $('#startButton');
      this.nextButton = $('#nextButton');
      this.completeTaskButton = $('#completeTaskButton');
      this.progressElem = $('#progressTextDiv');

      this.startButton.click(this.start.bind(this));
      this.nextButton.click(this.save.bind(this));
      this.completeTaskButton.click(this.showCoupon.bind(this));
      window.addEventListener('resize', this.onResize.bind(this), false);

      // Internal variables to track if task is ready to start or not
      // Set to true after launch and start button pressed
      this.__stateFlags = {};
      this.__waitingToStart = ['isLaunched', 'isStartTriggered']; // if all true, then start
      this.__isStarted = false;
      this.Subscribe('start', this, this.onStart.bind(this));
    }

    BaseTask.prototype = Object.create(PubSub.prototype);
    BaseTask.prototype.constructor = BaseTask;

    Object.defineProperty(BaseTask.prototype, 'isStarted', {
      get: function () {return this.__isStarted; }
    });

    BaseTask.prototype.setFlag = function(name, flag) {
      this.__stateFlags[name] = flag;
      this.__triggerStartWhenReady();
    };

    BaseTask.prototype.__triggerStartWhenReady = function () {
      console.log(this.__stateFlags);
      for (var i = 0; i < this.__waitingToStart.length; i++) {
        var name = this.__waitingToStart[i];
        if (!this.__stateFlags[name]) {
          return false;
        }
      }
      this.Publish('start', this);
      return true;
    };

    BaseTask.prototype.save = function() {
      var on_success = function(response) {
        this.next();
      }.bind(this);
      var on_error = function() {
        showAlert("Error saving results. Please close tab and do task again.");
      };

      var status = this.check();
      if (!status.error){
        var currentEntry = this.entries[this.entryIndex];
        if (status.summary) {
          this.summary[this.entryIndex] = status.summary;
        }
        if (status.results) {
          // This is included somewhere...
          submit_mturk_report_item(this.condition, currentEntry.id, status.results, undefined).error(on_error).success(on_success);
        }
      } else {
        bootbox.alert(status.error);
      }
    };

    BaseTask.prototype.check = function() {
      return {
        error: "Please implement me!!!"
      };
    };

    BaseTask.prototype.showComments = function() {
      // Hide rest of UI
      $('#ui').hide();
      // Show comment area
      $('#comment').show();
      // Focus on comments text box
      $('#comments').focus();
    };

    BaseTask.prototype.getComments = function() {
      return $('#comments').val();
    };

    BaseTask.prototype.showCoupon = function() {
      // TODO: Improve coupon
      var on_success = function(response) {
        document.body.innerHTML = "<p>Thanks for participating!</p>" +
          "<p>Your coupon code is: " + response.coupon_code + "</p>" +
          "Copy your code back to the first tab and close this tab when done.";
      };
      var on_error = function() { bootbox.alert("Error saving results. Please close tab and do task again.");};

      var comments = this.getComments();
      var results = {
        summary: this.summary,
        comments: comments
      };
      // This is included somewhere...
      submit_mturk_report(results).error(on_error).success(on_success);
    };

    BaseTask.prototype.next = function() {
      this.entryIndex++;
      if (this.entryIndex < this.entries.length) {
        // Launch next scene
        this.showEntry(this.entryIndex);
      } else {
        this.showComments();
      }
    };

    BaseTask.prototype.toFullUrl = function(url) {
      if (url.startsWith('/')) {
        url = this.base_url + url;
      }
      return url;
    };

    BaseTask.prototype.updateEntry = function(entry) {
    };

    BaseTask.prototype.showEntry = function(i) {
      var entry = this.entries[i];
      this.updateEntry(entry);
      this.updateProgress();
    };

    BaseTask.prototype.updateProgress = function() {
      var currentEntryIdx = this.entryIndex + 1; // one-indexed entry idx
      this.progressElem.text(currentEntryIdx + "/" + this.entries.length);
    };

    BaseTask.prototype.start = function() {
      this.taskInstructions.hide();
      this.mturkOverlay.show();
      this.mturkOverlay.css('visibility', 'visible');
      this.onResize();
      this.setFlag('isStartTriggered', true);
    };

    BaseTask.prototype.onStart = function() {
      // What to do when the task is first started!!!
      if (!this.__isStarted) {
        this.showEntry(this.entryIndex);
        this.__isStarted = true;
      }
    };

    BaseTask.prototype.showInstructions = function() {
      // TODO: Show instructions
    };

    BaseTask.prototype.Launch = function() {
      this.onResize();
      this.showInstructions();
      this.setFlag('isLaunched', true);
    };

    BaseTask.prototype.onResize = function() {
    };

    // Exports
    return BaseTask;
});

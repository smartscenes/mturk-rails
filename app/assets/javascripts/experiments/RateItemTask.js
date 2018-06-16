'use strict';

define(['./BaseTask', 'jquery', 'jquery.hotkeys', 'base'], function (BaseTask) {
    /**
     * Rate item task
     * - User is shown a series of items and asked to rate how good they are
     */
    function RateItemTask(params) {
      BaseTask.call(this, params);

      // Number of rating choices
      this.nChoices = params.conf['nChoices'];
      this.choices = params.conf['choices'];
      // Whether the label of the choice will be saved
      this.saveChoiceLabel = params.conf['saveChoiceLabel'];

      // Hook up UI behavior
      this.descriptionElem = $(params.descriptionElem || '#description');
      this.itemElem = $(params.itemElem || '#itemImage');
      this.ratingGroup = $(params.ratingGroup || '#ratingBtnGroup');

      // Set rating button click
      var taskState = this;
      this.ratingGroup.find('input[name=rating]').click(function() {
        //$(this).addClass('active').prop('checked', true).siblings().removeClass('active');
        var rating = $(this).val();
        taskState.select(rating, true);
      });
      // Also hook up rating keys to keyboard numbers
      for (var i = 1; i <= this.nChoices; i++) {
        $(document).bind('keydown', i.toString(), function(rating) {
          console.log(rating);
          taskState.select(rating, true);
        }.bind(this, i.toString()));
      }
    }

    RateItemTask.prototype = Object.create(BaseTask.prototype);
    RateItemTask.prototype.constructor = RateItemTask;

    RateItemTask.prototype.check = function() {
      // TODO: Check if the description is acceptable...
      var ok = (this.rating >= 1 && this.rating <= this.nChoices);
      if (ok){
        var currentEntry = this.entries[this.entryIndex];
        var label = this.choices? this.choices[this.rating] : undefined;
        var results = {
          rating: this.rating,
          entry: currentEntry
        };
        var summary = {
          entryId: currentEntry.id,
          rating: this.rating
        };
        if (label != undefined && this.saveChoiceLabel) {
          results['ratingLabel'] = label;
          summary['ratingLabel'] = label;
        }
        return {
          results: results,
          summary: summary
        }
      } else{
        return {
          error: "Please select a rating!"
        };
      }
    };

    RateItemTask.prototype.select = function (rating, save) {
      this.rating = rating;
      if (save) {
        this.save();
      }
    };

    RateItemTask.prototype.updateEntry = function(entry) {
      this.descriptionElem.text(entry['description'] || '');
      if (entry.url) {
        this.itemElem.attr('src', entry.url);
      }
      this.select(-1);
      // Reset radio selection
      $('input[name=rating]:checked').prop('checked', false);
      this.ratingGroup.find('label').removeClass('active');
    };

    // Exports
    return RateItemTask;
});

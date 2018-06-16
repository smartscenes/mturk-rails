'use strict';

// TODO: Global scope for runtime debugging, pull declaration into scope below
define(function(require) {
  require(['./SelectItemTask','jquery','base'], function(SelectItemTask) {
    $(document).ready(function() {
      $("img.enlarge").hover(function(){
        showLarge($(this));
      },function() {
      } );

      var selectItemTask = new SelectItemTask({
        base_url: window.globals.base_url,
        entries: window.globals.entries,
        conf: window.globals.conf
      });

      $('#instructionsToggle').click(function() { $( '#instructionsTextDiv' ).toggle(); });
      $('#help').show();
      selectItemTask.Launch();
    } );
  })
});

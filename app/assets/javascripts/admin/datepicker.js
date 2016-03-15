$(function() {
    $( ".js-datepicker-group" ).each(function(index, element){
      $(element).find(".js-from-date").datepicker({
        defaultDate: "+1w",
        changeMonth: true,
        changeYear: true,
        dateFormat: "yy-mm-dd",
        onClose: function( selectedDate ) {
          $(element).find( ".js-to-date" ).datepicker( "option", "minDate", selectedDate );
        }
      });

      $(element).find(".js-to-date").datepicker({
        defaultDate: "+1w",
        changeMonth: true,
        changeYear: true,
        dateFormat: "yy-mm-dd",
        onClose: function( selectedDate ) {
          $(element).find( ".js-from-date" ).datepicker( "option", "maxDate", selectedDate );
        }
      });
    });
});

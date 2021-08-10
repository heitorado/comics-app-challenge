$(document).on('turbolinks:load', function() {

  console.log('hi');

  $('.favourite-button-section').on ("ajax:success", toggleFavouriteButton)

  function toggleFavouriteButton(event){
    var data = event.detail[0]
    $(this).parent().find('.favourite-button-section').html(data.favourite_button);
  }

});


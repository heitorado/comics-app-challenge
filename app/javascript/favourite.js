$(document).on('turbolinks:load', function() {
  $('.favourite-button-section').on ("ajax:success", toggleFavouriteButton)

  function toggleFavouriteButton(event){
    var data = event.detail[0]
    $(this).parent().find('.favourite-button-section').html(data.favourite_button);
    $(this).parent().toggleClass('favourited');
    $(this).closest('.comic').toggleClass('favourited');
  }
});

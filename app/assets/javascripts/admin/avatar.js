window.addEventListener('DOMContentLoaded', function () {
  var identifier = ".js-avatar-edit ";
  var form = "#js-avatar-form"
  var avatarInput = identifier + '#js-avatar-input';
  var avatarPreview = identifier + '#js-avatar-preview';
  var cropDataField = identifier + 'input#crop_data';
  var avatarTrigger = ".js-avatar-trigger";
  var avatarModal = "#js-avatar-modal";
  var cropper;

  $(avatarTrigger).click(function(e) {
    $(avatarModal).modal('show')
  });

  $(form).submit(function (e) {
    if (cropper != null && cropper != undefined) {
      var data = JSON.stringify(cropper.getData());
      $(cropDataField).val(data);
    }
  });

  $(avatarInput).change(function(e) {
    return readURL(e.target);
  });

  function readURL(input) {
    if (input.files && input.files[0]) {
      var reader = new FileReader();
      reader.onload = function(e) {
        $(avatarPreview).attr('src', e.target.result);
        var image = $(avatarPreview)[0];
        if (cropper != null || cropper != undefined) {
          cropper.destroy();
          cropper = null;
        }
        cropper = new Cropper(image, {
          aspectRatio: 1,
          dragMode: "move",
          minCropBoxWidth: 200,
          minCropBoxHeight: 200,
          viewMode: 1,
          cropBoxMovable: false,
          cropBoxResizable: false,
          rotatable: false
          });
      };
      reader.readAsDataURL(input.files[0]);
    }
  }

  $('#js-avatar-modal').on('shown.bs.modal', function () {
    var image = $(avatarPreview)[0];
    cropper = new Cropper(image, {
      aspectRatio: 1,
      dragMode: "move",
      minCropBoxWidth: 200,
      minCropBoxHeight: 200,
      viewMode: 1,
      cropBoxMovable: false,
      cropBoxResizable: false,
      rotatable: false
    });
  }).on('hidden.bs.modal', function () {
    if (cropper != null || cropper != undefined) {
      cropper.destroy();
      cropper = null;
    }
  });
});

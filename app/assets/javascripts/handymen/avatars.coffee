Sels =
  avatarEdit: '.avatar-edit-page'

@AvatarEditPage =
  init: ->
    return unless $(Sels.avatarEdit).length
    $(@sels.avatarInput).change -> AvatarEditPage.readURL(@)
    $(@sels.avatarEditForm).submit (e) =>
      data = JSON.stringify(@cropper?.getData())
      $(@sels.cropDataField).val(data)

  readURL: (input) ->
    if input.files && input.files[0]
      reader = new FileReader()
      reader.onload = (e) =>
        $(@sels.avatarPreview).attr('src', e.target.result)
        image = $(@sels.avatarPreview)[0]
        @cropper?.destroy()
        @cropper = new Cropper(image,
          aspectRatio: 1
          minCropBoxWidth: 200
          minCropBoxHeight: 200
          viewMode: 1
          dragMode: 'move'
          cropBoxMovable: false
          cropBoxResizable: false
          rotatable: false
        )
      reader.readAsDataURL(input.files[0])

  sels:
    avatarInput:    "#{Sels.avatarEdit} .avatar-input"
    avatarPreview:  "#{Sels.avatarEdit} #avatar-preview"
    cropDataField:  "#{Sels.avatarEdit} input#crop_data"
    avatarEditForm: "#{Sels.avatarEdit} form#edit_profile"

  cropper: null

jQuery ->
  AvatarEditPage.init()

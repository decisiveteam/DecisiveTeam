// depends on image_cropper.css
import Cropper from 'cropperjs';

document.addEventListener('DOMContentLoaded', function() {
  const profileImage = document.getElementById('profile-image');
  const profileImageInput = document.getElementById('profile-image-input');
  const cropperModal = document.getElementById('cropper-modal');
  const cropperImage = document.getElementById('cropper-image');
  const cropButton = document.getElementById('crop-button');
  const croppedImageData = document.getElementById('cropped-image-data');
  const form = document.getElementById('profile-image-form');
  let cropper;

  profileImage.addEventListener('click', function() {
    profileImageInput.click();
  });

  profileImageInput.addEventListener('change', function(event) {
    const files = event.target.files;
    if (files && files.length > 0) {
      const reader = new FileReader();
      reader.onload = function(e) {
        cropperImage.src = e.target.result;
        cropperModal.style.display = 'block';
        cropper = new Cropper(cropperImage, {
          aspectRatio: 1,
          viewMode: 1
        });
      };
      reader.readAsDataURL(files[0]);
    }
  });

  cropButton.addEventListener('click', function() {
    const canvas = cropper.getCroppedCanvas();
    canvas.toBlob(function(blob) {
      const reader = new FileReader();
      reader.onloadend = function() {
        croppedImageData.value = reader.result;
        form.submit();
      };
      reader.readAsDataURL(blob);
    });
    cropperModal.style.display = 'none';
  });
});
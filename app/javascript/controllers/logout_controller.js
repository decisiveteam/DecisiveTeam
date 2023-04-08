import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  async logout(event) {
    event.preventDefault();

    const csrfToken = document.querySelector('meta[name="csrf-token"]').content;
    const response = await fetch('/logout', {
      method: 'DELETE',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrfToken
      },
      credentials: 'same-origin'
    });

    if (response.ok) {
      window.location.href = '/';
    } else {
      console.error('Logout failed:', response.statusText);
    }
  }
}

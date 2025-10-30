window.onload = function () {
  google.accounts.id.initialize({
    client_id: "208804397507-gk0vubpjuj28b0mntiqkbagh5bje1e5d.apps.googleusercontent.com", // 👈 Replace this!
    callback: handleCredentialResponse
  });

  google.accounts.id.renderButton(
    document.getElementById("googleSignInDiv"),
    { theme: "outline", size: "large" }
  );
};

function handleCredentialResponse(response) {
  const idToken = response.credential;
  console.log("✅ Google ID Token received:", idToken);

  // Emit a custom event that Flutter can listen for
  window.dispatchEvent(new CustomEvent("google-login", { detail: idToken }));
}



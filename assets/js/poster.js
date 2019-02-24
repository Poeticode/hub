const post_button = document.querySelector("#post_btn");
const author = document.querySelector("#post_author");
const title = document.querySelector("#post_title");
const content = document.querySelector("#post_content");
const token = document.querySelector("#token");
const result = document.querySelector("#post_errors");

if (post_button) {
    console.log("setting up btn");
    post_button.addEventListener("click", handlePostSubmission);
}

function handlePostSubmission() {
    console.log(author.value);
    console.log(title.value);
    console.log(content.value);
    postData(`/create_post`, {
            post: {
                author: author.value,
                title: title.value,
                content: content.value
            }
        },
        token.value)
        .then((data) => {
            console.log(data);
            if (data.errors) {
                handleErrors(data.errors);
            } else {
                if (data.message) {
                    result.innerHTML += data.message;
                }
            }
            // console.log(JSON.stringify(data))
        }) // JSON-string from `response.json()` call
        .catch((errors) => {
            console.log(errors);
        });
}

function handleErrors(error) {
    let all_errors = ""
    if (!error) return;
    if (error.detail) {
        all_errors += `${error.detail}, `;
    }
    if (error.author) {
        // we got some author problems
        error.author.forEach(err => {
            all_errors += `Author ${err}, `;
        });
    }
    if (error.title) {
        // we got some title problems
        error.title.forEach(err => {
            all_errors += `Title ${err}, `;
        });
    }
    if (error.content) {
        // we got some content problems
        error.content.forEach(err => {
            all_errors += `Content ${err}, `;
        });
    }
    result.innerHTML = all_errors;
}

// stolen from https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API/Using_Fetch
function postData(url = ``, data = {}, token = ``) {
    // Default options are marked with *
      return fetch(url, {
          method: "POST", // *GET, POST, PUT, DELETE, etc.
          mode: "cors", // no-cors, cors, *same-origin
          cache: "no-cache", // *default, no-cache, reload, force-cache, only-if-cached
          credentials: "same-origin", // include, *same-origin, omit
          headers: {
              "Content-Type": "application/json",
              "x-csrf-token": token
              // "Content-Type": "application/x-www-form-urlencoded",
          },
          redirect: "follow", // manual, *follow, error
          referrer: "no-referrer", // no-referrer, *client
          body: JSON.stringify(data), // body data type must match "Content-Type" header
      })
      .then(response => response.json()); // parses response to JSON
}
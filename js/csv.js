$("form").submit(function(event) {
  var fields = ["#first_name", "#last_name", "#dot_number", "#email", "#interests", "#games"];

  var line = [];

  for (let field of fields) {
    if (field === "#interests" || field === "#games") {
      for (let checkbox of $(field).children().children().children()) {
        line.push(String($(checkbox).prop("checked")));
        $(checkbox).prop("checked", false);
      }
    } else {
      line.push($(field).val());
      $(field).val("");
    }
  }

  line = String(line).concat("\r\n");

  fs.appendFile("C:/Users/dsoll/Desktop/test.csv", line, function (err) {
      if(err){
          alert("An error ocurred creating the file "+ err.message);
      }
  });
});

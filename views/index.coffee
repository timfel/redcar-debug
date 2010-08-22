$(document).ready ->
  input = $("#input")
  output = $("#output")
  input.focus()

  $(".notebook").children(".tab").click (e) ->
    e.preventDefault()
    $(this).siblings().addClass("disabled")
    $(this).removeClass("disabled")
    $(this).parent().children(".window").children("span").hide()
    output_buffer = "#" + $(this).attr("id").replace("-tab","")
    $(output_buffer).show()
    
  $("form").submit (e) ->
    e.preventDefault()
    value = input.val()
    output.append "<span class=\"stdout\">" + value + "<br></span>"
    # Just push the data, output comes from debugger
    try
      # Call the Controller. FIXME: Why is the Controller const not available here?
      rubyCall "input", ["stdin_ready", value]
    catch error
      alert error.message
    input.val ""
    input.focus()


inHours = (start, end) ->
  if start <= new Date().getHours() < end
    true
  else
    false

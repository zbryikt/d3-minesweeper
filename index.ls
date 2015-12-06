<- $ document .ready

generate = (w,h) -> 
  board = for y from 0 til h => for x from 0 til w => {mine: (if Math.random!>0.9 => true else false), x, y}
  flat = board.reduce(((a,b) -> a ++ b), [])
  for item in flat => item.board = board
  {board, flat}

iterate = (w, h, board) ->
  cont = false
  for y from 0 til h => for x from 0 til w =>
    if board[y][x].check and !board[y][x].checked =>
      board[y][x].show = true
      board[y][x].count = (
        for dy from -1 to 1 => for dx from -1 to 1 => 
          [cx, cy] = [x + dx, y + dy]
          if cx < 0 or cy < 0 or cx >= w or cy >= h => 0
          else board[y + dy >? 0 <? h - 1][x + dx >? 0 <? w - 1].mine
      ).reduce(((a,b) -> a ++ b), []).reduce(((a,b) -> a + b),0)
      board[y][x].checked = true
      if board[y][x].mine => board.failed = true
      if board[y][x].count == 0 =>
        cont = true
        for dy from -1 to 1 => for dx from -1 to 1 =>
          board[y + dy >? 0 <? h - 1][x + dx >? 0 <? w - 1].check = true
  if cont => iterate w, h, board
  else render w, h

init = (w,h) ->
  {board,flat} = generate w, h
  d3.select \#field .selectAll \.block .data flat
    ..enter!append \div
      .attr do
        class: \block
      .style do
        top: -> "#{100 * (it.y / h)}%"
        left: -> "#{100 * (it.x / w)}%"
        width: -> "#{100/w}%"
        height: -> "#{100/h}%"
      .on \click -> 
        if it.board.failed => return
        it.board[it.y][it.x].check = true
        iterate w, h, it.board
    ..exit!remove!
  render w,h

render = (w,h) ->
  d3.select \#field .selectAll \.block
    ..text -> if it.count => that else ""
    ..style do
      background: -> 
        if it.count? and it.mine => return \#f00
        if !it.count? => \#ddd else if it.count == 0 => \#fff else \#eee
      color: ->
        if it.count? => <[#999 #009 #090 #990 #900 #940 #490 #049 #000]>[it.count] else \#000
      "font-size": -> "#{$(@)width!}px"
      "line-height": -> "#{$(@)height!}px"

window.reset = reset = -> init 10, 10

reset!

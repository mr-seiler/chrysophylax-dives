turnLeft = true
turnRight = not turnLeft

flipBools = (boolarr) ->
    return boolarr.map(
        (current, idx, arr) ->
            return not current
    )

# given N, return an array describing the turns the dragon path should take
# returns the path as an array of boolean true for left, false for right
getTurns = (n) ->
    if n == 1
        return [ turnLeft ]
    else
        # recur
        leftPart = getTurns(n - 1)
        # copy
        rightPart = flipBools(leftPart[..].reverse())
        return leftPart.concat([ turnLeft ], rightPart)


# main dragon drawing function
drawCurve = (n) ->
    n = Number(n)
    # draw the curve here
    letters = getTurns(n).map(
        (current, idx, arr) ->
            return if current == turnLeft then "L" else "R"
    )
    console.log(letters)

# register key event listener on text input so we can act when the enter key is pressed
document.getElementById('input-n').addEventListener("keyup",
    (event) ->
        if event.keyCode == 13
            source = event.target
            drawCurve(source.value)

)

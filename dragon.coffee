# Ideas:
# - when using squares, optionally fill the path (would that work?)
# - arcTo to draw curved path instead of squares
# - experiment with different stroke styles (color gradient?)
# - color options (path and background)
# - fix text input size
# - VALIDATION

# define relative directions
turnLeft = true
turnRight = not turnLeft

# define absolute directions;
# north and south jump values inverted for canvas coords

makeDirections = (length) ->
    return {
        "NORTH": {
            onLeft: "WEST",
            onRight: "EAST",
            jump: {x: 0, y: -length}
        },
        "SOUTH": {
            onLeft: "EAST",
            onRight: "WEST",
            jump: {x: 0, y: length}
        },
        "EAST": {
            onLeft: "NORTH",
            onRight: "SOUTH",
            jump: {x: length, y: 0}
        },
        "WEST": {
            onLeft: "SOUTH",
            onRight: "NORTH",
            jump: {x: -length, y: 0}
        }
    }


makePoint = (xv, yv) ->
    return {x: xv, y: yv}


makePointGenerator = (initialPoint, initialDir, slen) ->
    directions = makeDirections(slen)
    lastPoint = initialPoint
    lastDir = initialDir

    return (turn) ->
        # determine next absolute direction based on the turn given
        # and the last direction we moved
        nextDir = if turn == turnLeft then directions[lastDir].onLeft else directions[lastDir].onRight
        # calculate the next point coords
        offset = directions[nextDir].jump
        nextPoint = makePoint(
            lastPoint.x + offset.x,
            lastPoint.y + offset.y
        )
        # cache state for next call
        lastDir = nextDir
        lastPoint = nextPoint
        # return the point
        return nextPoint


# given array of "turns" generate an array of relative points for the path
# we'll need to translate these later, and possible scale them as well?
# NOTE THAT THESE ARE IN CANVAS COORDS, so the Y axis is "inverted"
getPoints = (turnArray, slen) ->
    # start with the first two points
    firstPoint = makePoint(0, 0)
    secondPoint = makePoint(-slen, 0)
    initialDir = "WEST"

    # callable generator
    nextPoint = makePointGenerator(secondPoint, initialDir, slen)

    # start the aray
    points = [ firstPoint, secondPoint ]

    # go through the array and generate relative points
    points.push(nextPoint(turn)) for turn in turnArray

    return points


# Reutrns an object containing maximum and minumum x and y values
# from the array of points as well as functions to calculate the
# width and height of the set of points
getDimenSpec = (pointArray) ->
    spec = {
        max: { x: undefined, y: undefined },
        min: { x: undefined, y: undefined },
        width: (() ->
            return @max.x - @min.x),
        height: (() ->
            return @max.y - @min.y)
    }

    # helper function to update max and min in the spec from a point
    updateMaxMin = (point) ->
        spec.max.x = point.x if point.x > spec.max.x or spec.max.x == undefined
        spec.max.y = point.y if point.y > spec.max.y or spec.max.y == undefined
        spec.min.x = point.x if point.x < spec.min.x or spec.min.x == undefined
        spec.min.y = point.y if point.y < spec.min.y or spec.min.y == undefined
        return true

    # use comprehension forEach
    updateMaxMin(point) for point in pointArray

    return spec


# given N, return an array describing the turns the dragon path should take
# returns the path as an array of boolean true for left, false for right
getTurns = (n) ->
    if n == 0
        return []
    else
        # recur
        leftPart = getTurns(n - 1)
        # copy
        rightPart = leftPart[..].reverse().map((val) -> not val)
        return leftPart.concat([ turnLeft ], rightPart)


# main dragon drawing function
# FIXME obviously, this needs to be decomposed
drawCurve = (n, s) ->
    # this is... primitive
    n = 20 if n > 20
    s = 10 if s < 2 or s > 20

    # get array of point coordinates
    points = getPoints(getTurns(n), s)
    dimenSpec = getDimenSpec(points)

    # figure out the width and height of the viewport -
    # we'll use this as the maximum for the canvas size
    # (minus some padding)
    viewWidth = window.innerWidth - 50
    viewHeight = window.innerHeight - 50

    #  get the canvas and draw stuff
    canvas = document.getElementById("dragon")

    ctx = canvas.getContext("2d")

    # canvas transforms should be more efficient than trying
    # to translate/scale points in the array, right?

    # size the canvas to the size of the drawing (+5 padding)
    canvas.width = dimenSpec.width() + 5
    canvas.height = dimenSpec.height() + 5

    # translate the drawing so negative coords are shifted to >= 0
    movex = movey = 0.5
    movex = movex + (0 - dimenSpec.min.x) if dimenSpec.min.x < 0
    movey = movey + (0 - dimenSpec.min.y) if dimenSpec.min.y < 0
    if movex > 0 or movey > 0
        ctx.translate(movex, movey)

    # create and draw the path
    ctx.beginPath()
    ctx.moveTo(points[0].x, points[0].y)
    ctx.lineTo(pt.x, pt.y) for pt in points[1..]

    ctx.strokeStyle = "black"
    ctx.lineCap = "round"
    ctx.lineJoin = "round"
    ctx.stroke()

    return "yikes"


sizeField = document.getElementById('input-size')
nField = document.getElementById('input-n')

# register key event listener on text input so we can act when the enter key is pressed
onEnter = (event) ->
    if event.keyCode == 13
        # do stuff
        s = Number(sizeField.value)
        n = Number(nField.value)
        drawCurve(n, s)


sizeField.addEventListener("keyup", onEnter)
nField.addEventListener("keyup", onEnter)

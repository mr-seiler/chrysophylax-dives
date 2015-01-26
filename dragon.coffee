# define relative directions
turnLeft = true
turnRight = not turnLeft

# define absolute directions;
# north and south jump values inverted for canvas coords
directions = {
    "NORTH": {
        onLeft: "WEST",
        onRight: "EAST",
        jump: {x: 0, y: -1}
    },
    "SOUTH": {
        onLeft: "EAST",
        onRight: "WEST",
        jump: {x: 0, y: 1}
    },
    "EAST": {
        onLeft: "NORTH",
        onRight: "SOUTH",
        jump: {x: 1, y: 0}
    },
    "WEST": {
        onLeft: "SOUTH",
        onRight: "NORTH",
        jump: {x: -1, y: 0}
    }
}


makePoint = (xv, yv) ->
    return {x: xv, y: yv}


makePointGenerator = (initialPoint, initialDir) ->
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
getPoints = (turnArray) ->
    # start with the first two points
    firstPoint = makePoint(0, 0)
    secondPoint = makePoint(-1, 0)
    initialDir = "WEST"

    # callable generator
    nextPoint = makePointGenerator(secondPoint, initialDir)

    # start the aray
    points = [ firstPoint, secondPoint ]

    # go through the array and generate relative points
    points.push(nextPoint(turn)) for turn in turnArray

    return points

# create a new point array with all the point coordinates multiplied by a scalar
scalePoints = (pointArray, scalar = 0) ->
    # helper function creates a new, scaled point
    scalePoint = (pt) ->
        return makePoint(pt.x * scalar, pt.y * scalar)

    return (scalePoint(point, scalar) for point in pointArray)


# create a new point array with each point translated by a specified x and y amount
translatePoints = (pointArray, x = 0, y = 0) ->
    # helper function creates a new, translated point
    translatePt = (pt) ->
        return makePoint(pt.x + x, pt.y + y)
    # return map comprehension
    return (translatePt(point) for point in pointArray)


# Reutrns an object containing maximum and minumum x and y values
# from the array of points as well as functions to calculate the
# width and height of the set of points
getDimenSpec = (pointArray) ->
    spec = {
        max: { x: 0, y: 0 },
        min: { x: 0, y: 0 },
        width: (() ->
            return @max.x - @min.x),
        height: (() ->
            return @max.y - @min.y)
    }

    # helper function to update max and min in the spec from a point
    updateMaxMin = (point) ->
        spec.max.x = point.x if point.x > spec.max.x
        spec.max.y = point.y if point.y > spec.max.y
        spec.min.x = point.x if point.x < spec.max.x
        spec.min.y = point.y if point.y < spec.min.y
        return true

    # use comprehension forEach
    updateMaxMin(point) for point in pointArray

    return spec


# given N, return an array describing the turns the dragon path should take
# returns the path as an array of boolean true for left, false for right
getTurns = (n) ->
    if n == 1
        return [ turnLeft ]
    else
        # recur
        leftPart = getTurns(n - 1)
        # copy
        rightPart = leftPart[..].reverse().map((val) -> not val)
        return leftPart.concat([ turnLeft ], rightPart)


# main dragon drawing function
drawCurve = (n) ->
    n = Number(n)
    n = 10 if n > 10
    # draw the curve here
    temp = getPoints(getTurns(n))
    console.log(temp)
    dimenSpec = getDimenSpec(temp)
    console.log(dimenSpec.width())
    console.log(dimenSpec.height())




# register key event listener on text input so we can act when the enter key is pressed
document.getElementById('input-n').addEventListener("keyup",
    (event) ->
        if event.keyCode == 13
            source = event.target
            drawCurve(source.value)

)

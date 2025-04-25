$x = "test"

function test($y) {
    $global:x = $y
}
test("neuer Test")
echo $x


$neueVariable
$camelCaseSchreibweise
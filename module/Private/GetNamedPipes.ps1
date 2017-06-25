using namespace System.Collections.Generic
using namespace System.Linq.Expressions

# Need to invoke a non-public method that has ByRef parameters. Typically the powershell engine
# handles ByRef behind the scenes but parameter binding needs to be explicit when using reflection.
# Because of this I needed to create a proxy method and I wanted to avoid inline C#.
function GetNamedPipes {
    # Get the private method in the private type.
    $nativeEnumerateDirectory = [ref].Assembly.
        GetType('System.Management.Automation.Utils').
        GetMethod('NativeEnumerateDirectory', 60)

    # Expressions that declare the variables for the block.
    $params = [Expression]::Variable([string], 'directory'),
              [Expression]::Variable([List[string]], 'directories'),
              [Expression]::Variable([List[string]], 'files') -as [ParameterExpression[]]

    $body = # An expression that assigns the only parameter that isn't by ref.
            [Expression]::Assign($params[0], [Expression]::Constant('\\.\pipe', [string])),
            # An expression that invokes our target method.
            [Expression]::Call($nativeEnumerateDirectory, $params[0], $params[1], $params[2]),
            # Return the files variable. Note: the entire array is cast as Expression[], not this var.
            $params[2] -as [Expression[]]

    # Combine the expressions into a block expression, then into a lambda expression and compile.
    $method = [Expression]::Lambda([Expression]::Block($params, $body)).Compile()

    return $method.Invoke()
}

## Formatting

We mainly base our formatting on the Google style built into LLVM's clang-format utility.
While the format of source code files does not affect the compile- or run-time characteristics
of the code, it has a profound effect on readability and how easy it is for a developer to read
and maintain the code.



### Line Length

Each line of text in your code should be at most 100 characters long.

Though we no longer limit ourselves to 80 columns, we frequently find ourselves developing on
laptops with limited screen width. Scrolling and line wrapping in many editors is inconsistent and
the developer's focus is drawn away.


### Open Bracket

Open brackets should exist on a new line, indented to the point of the previous line.

```cpp
int
function(
    int arg)
{
    if (arg == 42)
    {
        return 42;
    }
    return 0;
}
```

An exception to this is the extern block, for reasons of not force-indenting the rest of the file
contained in the `extern`ed code.

```cpp
extern "C" {

int
foonction(
    int arg1,
    int arg2);

}
```

### Indentation
Use 4 spaces for indentation. Do not use tabs, please.

Please do not indent case labels.
Please do not indent function declarations after the return type.
Please do not indent wrapped function names.

For the same reason as the `extern` block above, we do not indent namespaces.
Given a strict columnar limit, wasted space to the left makes code harder to read, due to the
wrapping that often happens.

### Shorties
We disable allowing short blocks, case labels, if statements, loops, functions to be put on a
single line. This, again, is for readability.

### Alignment
Consistent alignment helps the eye quickly find differences.
Please align consecutive assignments, escaped newlines (to the left), operands, trailing
comments.

We align pointers and references to the right.

```cpp

const std::string &longBlockOfText = gatherText();
const char *pbuf = longBlockOfText.c_str();
```

### Function Declarations and Definitions

Function definitions can elide unused parameters, but function declaration should not.
Leaving out a function argument in the definition is often the simplest method for suppressing
a warning about a variable not being used.

However, the declaration of the function needs to have the parameter listed and explained in
a brief comment, so a future implementer is able to understand what it is for.

### Spaces or Tabs
As mentioned above, spaces. It's meant for consistency across editors and displays.

### Readability
We insert a space between control identifiers (`if`, `while`, etc) and the open-parenthesis.

We also insert a space between the assignment operator.

```cpp
int count = 0;
while (true)
{
    if (++count > 5)
    {
        break;
    }

    std::cout << "looped again!" << std::endl;
}
```
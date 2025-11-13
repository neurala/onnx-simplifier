This repo is fork of original repo: [https://github.com/daquexian/onnx-simplifier](https://github.com/daquexian/onnx-simplifier/pulls)  

Main issue in: [onnx_simplifier.py](https://github.com/daquexian/onnx-simplifier/blob/master/onnxsim/onnx_simplifier.py)

```python
    # https://stackoverflow.com/a/60708339
    def parse_size(size: str) -> int:
        units = {"B": 1, "KB": 2**10, "MB": 2**20, "GB": 2**30, "TB": 2**40}
        size = size.upper()
        if not re.match(r' ', size):
            size = re.sub(r'([KMGT]?B)', r' \1', size)
        number, unit = [string.strip() for string in size.split()]
        return int(float(number)*units[unit])
```

Code snippet which is copied from stackoverflow, which creates
license violation.


## Quick instructions for building the wheel:

Download onnx-simplifier fork w/ the correct branch, including submodules  
Ensure CMake is installed  
Create virtual environment and run pip install . to install dependencies  
Finally, run python setup.py bdist_wheel  

If you receive an error regarding CMake version 3.5 not being supported by your version of CMake (which is likely if you're running a CMake version used to build the SDK), then setting the following variable should resolve any issue:  

linux: `export CMAKE_POLICY_VERSION_MINIMUM=3.5`  
powershell:`$Env:CMAKE_POLICY_VERSION_MINIMUM=3.5`  

onnx-simplifier has a set of CMake files for itself, and one of the submodules is onnx and has a set of CMake files.

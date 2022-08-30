#                          PyPI Package Uploader
#                         By Oliver's Tech Corner


# Overall try-finally is for Ctrl+C detection
try {
# Variable Creation
$package_name = $null
$file_names = @()
$version = $null
$description = $null
$user = $null
$password = $null
$author_email = $null
$url = $null
$install_requires = $null
$project_folder = $null
$dev_status = $null

$previous_location = Get-Location

Clear-Host

Write-Host "          PYPI Package Uploader Tool          " -BackgroundColor Blue -ForegroundColor Black
Write-Host "-By Oliver's Tech Corner-" -ForegroundColor Green
Write-Host "`nThis is a tool to help users upload python packages to PyPI easily."
Write-Host "Tip: If you see something in [square brackets], it's the default value!"
Write-Host "`nPress any key to begin." -NoNewline
[void][System.Console]::ReadKey($true)

Clear-Host

# Step 1
Write-Host "                     Step 1: Basic Info                     " -BackgroundColor Green -ForegroundColor Black
Write-Host "In this step, you'll be asked to enter some information you'd like to include with your PyPI package."
Write-Host "-----------------"
while ($true) {
$package_name = Read-Host "Name for your package (shown on PyPI)"
if ($null -eq $package_name -or $package_name -eq '') {
    Write-Host "Package name empty, please try again" -ForegroundColor Red
    continue
}
else {
    Write-Host "Package name is not empty" -ForegroundColor Green
    try {
    Invoke-WebRequest "https://pypi.org/project/$package_name" | Out-Null
    Write-Host "Project already exists." -ForegroundColor Red
    Write-Host "You can continue if it is yours.`nIs the package yours? (Y/N) " -ForegroundColor Blue -NoNewline
    $exists_continue = Read-Host "[N]"
    if ($exists_continue -eq '' -or $null -eq $exists_continue) {$how_many_files = 'n'}
    if ($exists_continue -eq 'y') {
        break
    }
    else {
        continue
    }

    continue
    }
    catch {
        Write-Host "Project doesn't exist yet" -ForegroundColor Green
        break
    }
}
}
$how_many_files_str = Read-Host "`nAmount of files as integer [1]"
if ($how_many_files_str -eq '' -or $null -eq $how_many_files_str) {$how_many_files = 1}
else {$how_many_files = [int]$how_many_files_str}
$i = 1
while ($i -le $how_many_files) {    
    while ($true) {
        $tmp_file_name = Read-Host "Name of File $i"
        $tmp_file_name = $tmp_file_name.trimEnd(".py")
        if ($tmp_file_name -eq '' -or $null -eq $tmp_file_name) {
            Write-Host "Name cannot be blank" -ForegroundColor Red
            continue
        }
        else {
            break
        }
    }
    $file_names += $tmp_file_name
    $i = $i + 1
}
$version = Read-Host "`nVersion number for package [0.1]"
if ($version -eq '' -or $null -eq $version){$version = '0.1'}

Write-Host "-----------------------"
Write-Host "Creating temporary directory for package $package_name..."

$temp = $env:temp
$project_folder = "$($temp)\pypipackage_$($package_name)"

New-Item -Path $project_folder -ItemType Directory | Out-Null

$description = Read-Host "`nDescription of package [none]"
if ($null -eq $description) {$description = ''}
while ($true) {
$user = Read-Host "PyPI Username"
if ($user -eq '' -or $null -eq $user) {
    Write-Host "Username cannot be blank" -ForegroundColor Red
    continue
}
else {
    break
}
}
while ($true) {
    $password = Read-Host "PyPI Password"
    if ($password -eq '' -or $null -eq $password) {
        Write-Host "Password cannot be blank" -ForegroundColor Red
        continue
    }
    else {
        break
    }
}

while ($true) {
$author_email = Read-Host "Your email"
if ($author_email -eq '' -or $null -eq $author_email) {
    Write-Host "Email cannot be blank" -ForegroundColor Red
    continue
}
elseif ($author_email -like "*@*" -eq $false) {
    Write-Host "Email not formatted correctly" -ForegroundColor Red
    continue
}
else {
    break
}
}

while ($true) {
$url = Read-Host "URL of Repository or website"

if ($url -eq '' -or $null -eq $url) {
    Write-Host "Site URL cannot be blank" -ForegroundColor Red
    continue
}
elseif ($url -like "http*" -eq $false) {
    Write-Host "URL not formed properly (did you forget http://?)" -ForegroundColor Red
    continue
}
else {
    break
}
}

$install_requires = Read-Host "Required dependencies (seperate with comma)"
if ($install_requires -like '*,*') {
    $install_requires = $install_requires.split(',')
}

while ($true) {
$dev_status = Read-Host "Enter development status - Alpha, Beta or Stable"
if ($dev_status -eq 'alpha') {
    $dev_status = "3 - Alpha"
    break
}
elseif ($dev_status -eq 'beta') {
    $dev_status = "4 - Beta"
    break
}
elseif ($dev_status -eq 'stable') {
    $dev_status = "5 - Production/Stable"
    break
}
else {
    Write-Host "Invalid entry" -ForegroundColor Red
    continue
}
}

# Step 2
Clear-Host
Write-Host "                     Step 2: setup.py building                   " -BackgroundColor Cyan -ForegroundColor Black
Write-Host "Building setup.py..."

$install_requires = $install_requires.Replace(' ', '')
$require_list = '['
foreach ($requirement in $install_requires) {
    $require_list += "'$requirement', "
}
$require_list = $require_list.TrimEnd(', ')
$require_list += ']'


$setup_py_code = @"
from distutils.core import setup
setup(
  name = '$package_name',         
  packages = ['$package_name'],   
  version = '$version',        
  description = '$description',   
  author = '$user',                   
  author_email = '$author_email',      
  url = '$url',   
  install_requires=$require_list,
  classifiers=[
    'Development Status :: $dev_status',      
    'Intended Audience :: Developers',      
    'Topic :: Software Development :: Build Tools',
    'Programming Language :: Python :: 3',      
    'Programming Language :: Python :: 3.4',
    'Programming Language :: Python :: 3.5',
    'Programming Language :: Python :: 3.6',
  ],
)
"@

$setup_py_code | Out-File -FilePath "$project_folder\setup.py" -encoding utf8

while ($true) {
Write-Host "setup.py has been built. Would you like to view it? (Y/N) " -ForegroundColor Green -NoNewline
$view_setup_py = Read-Host "[Y]"

if ($view_setup_py -eq 'y' -or $view_setup_py -eq '' -or $null -eq $view_setup_py) {
    Start-Process "explorer.exe" -ArgumentList "/select,$project_folder\setup.py" |Out-Null
    Write-Host "Opened in Explorer"
    Write-Host "`nPress any key to continue." -NoNewline
    [void][System.Console]::ReadKey($true)
    break
}
elseif ($view_setup_py -eq 'n') {
    break
}
else {
    Write-Host "Invalid choice" -ForegroundColor Red
    continue
}
}

# Step 3
Clear-Host
Write-Host "                     Step 3: __init__.py building                   " -BackgroundColor Yellow -ForegroundColor Black

New-Item "$project_folder\__init__.py" |Out-Null
foreach ($file in $file_names) {
    Add-Content "$project_folder\__init__.py" -value "import $package_name.$file" -encoding UTF8 |Out-Null
}

while ($true) {
    Write-Host "__init__.py has been built. Would you like to view it? (Y/N) " -ForegroundColor Green -NoNewline
    $view_init_py = Read-Host "[Y]"
    
    if ($view_init_py -eq 'y' -or $view_init_py -eq '' -or $null -eq $view_init_py) {
        Start-Process "explorer.exe" -ArgumentList "/select,$project_folder\__init__.py" |Out-Null
        Write-Host "Opened in Explorer"
        Write-Host "`nPress any key to continue." -NoNewline
        [void][System.Console]::ReadKey($true)
        break
    }
    elseif ($view_init_py -eq 'n') {
        break
    }
    else {
        Write-Host "Invalid choice" -ForegroundColor Red
        continue
    }
}

# Step 4
Clear-Host
Write-Host "                     Step 4: Copying your python files                  " -BackgroundColor White -ForegroundColor Black
Write-Host "For this step, you'll need to copy all your Python files into the project directory. The specified Python files you gave earlier were: `n$file_names`nPress any key to open the project directory, then copy the files into it." -NoNewline
[void][System.Console]::ReadKey($true)
Start-Process "explorer.exe" -ArgumentList "$project_folder" |Out-Null
Write-Host "`nOnce you've copied your Python scripts into the folder, press any key." -NoNewline
[void][System.Console]::ReadKey($true)

# Step 5
Clear-Host
Write-Host "                     Step 5: Uploading to PyPI                  " -BackgroundColor Black -ForegroundColor White
Write-Host "This is the final step! After this, your package will be live on PyPI.`n"
Write-Host "Copying all files to subdirectory"
New-Item "$project_folder\$package_name\" -ItemType Directory -Force
Copy-Item -Path "$project_folder\*" -Destination "$project_folder\$package_name\" -Force
Write-Host "Preparing for PyPI upload"
Set-Location -Path $project_folder
py.exe "$project_folder\setup.py" sdist
Write-Host "Installing Twine if required"
py.exe -m pip install twine
Write-Host "Uploading to PyPI!"
py.exe -m twine upload dist/* -u $user -p $password

try {
    py.exe -m twine upload dist/* -u $user -p $password
    Clear-Host
    Write-Host "Your package is now up!`nhttps://pypi.org/project/$package_name/$version" -ForegroundColor Green

}
catch  {
    Write-Host "Error occurred!" -ForegroundColor Red
    Write-Host $_.ScriptStackTrace
}


Write-Host "--------------------------" 

Write-Host "Press any key to exit..."
[void][System.Console]::ReadKey($true)
Clear-Host
Write-Host "Script by Oliver's Tech Corner`nThank you for using my project, it means a lot to me :)" -BackgroundColor Black -ForegroundColor Green
Start-Sleep 5
Clear-Host

}
finally {
    Write-Host "`n-----Script Completed-----`nCleaning up..." -ForegroundColor Green

    try {
    Remove-Item $project_folder -ErrorAction Stop
    }
    catch {
        Write-Host "Couldn't delete directory." -ForegroundColor Blue
    }
    
    Write-Host "-------"
    Set-Location $previous_location
    
}

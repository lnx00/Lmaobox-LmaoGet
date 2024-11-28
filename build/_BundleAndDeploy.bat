@echo off

node bundle.js
move /Y ".\out\LmaoGet.lua" "%localappdata%"
pause
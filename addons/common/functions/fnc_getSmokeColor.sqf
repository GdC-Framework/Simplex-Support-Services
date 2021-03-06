#include "script_component.hpp"

params ["_smoke"];

private _smokeColor = getArray (configfile >> "CfgAmmo" >> typeOf _smoke >> "smokeColor");
_smokeColor deleteAt 3;

private _rgbDistances = [];
{
	_x params ["_name","_RGB"];
	_rgbDistances pushBack [_smokeColor distance _RGB,_name];
} forEach [
	["white",[1,1,1]],
	["black",[0,0,0]],
	["red",[0.8438,0.1383,0.1353]],
	["orange",[0.6697,0.2275,0.10053]],
	["yellow",[0.9883,0.8606,0.0719]],
	["green",[0.2125,0.6258,0.4891]],
	["blue",[0.1183,0.1867,1]],
	["purple",[0.4341,0.1388,0.4144]]
];
_rgbDistances sort true;

_rgbDistances # 0 # 1


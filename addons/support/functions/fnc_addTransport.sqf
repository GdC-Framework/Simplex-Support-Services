#include "script_component.hpp"

params [
	["_vehicle",objNull,[objNull]],
	["_callsign","",[""]],
	["_respawnTime",DEFAULT_RESPAWN_TIME,[0]],
	["_customInit",{},[{},""]],
	["_accessItems",[],[[]]],
	["_accessCondition",{true},[{},""]],
	["_requestCondition",{true},[{},""]]
];

// Validation
if (_callsign isEqualTo "") then {
	_callsign = getText (configFile >> "CfgVehicles" >> typeOf _vehicle >> "displayName");
};

if (_customInit isEqualType "") then {
	_customInit = compile _customInit;
};

if (_accessCondition isEqualType "") then {
	_accessCondition = compile _accessCondition;
};

if (_requestCondition isEqualType "") then {
	_requestCondition = compile _requestCondition;
};

if (!isNull (_vehicle getVariable ["SSS_parentEntity",objNull])) exitWith {
	SSS_ERROR_2(LLSTRING(VehicleAlreadyASupport),_callsign,_vehicle);
	objNull
};

if ({isPlayer _x} count crew _vehicle > 0) exitWith {
	SSS_ERROR_2(LLSTRING(NoPlayersAllowed),_callsign,_vehicle);
	objNull
};

if (!alive driver _vehicle) exitWith {
	SSS_ERROR_2(LLSTRING(NoDriverInVehicle),_callsign,_vehicle);
	objNull
};

if (!isServer) exitWith {
	_this remoteExecCall [QFUNC(addTransport),2];
	objNull
};

// Basic setup
private _entity = true call CBA_fnc_createNamespace;
private _group = group _vehicle;
private _side = side _group;

switch (true) do {
	case (_vehicle isKindOf "Helicopter") : {
		BASE_TRAITS(_entity,typeOf _vehicle,_callsign,_side,ICON_HELI,_customInit,"Transport","transportHelicopter",_accessItems,_accessCondition,_requestCondition);
		PHYSICAL_TRAITS(_entity,_vehicle,_group,getPosASL _vehicle,_respawnTime);
		CREATE_TASK_MARKER(_entity,_callsign,"mil_end",LLSTRING(AirTransport));

		// Specifics
		_entity setVariable ["SSS_awayFromBase",false,true];
		_entity setVariable ["SSS_onTask",false,true];
		_entity setVariable ["SSS_interrupt",false,true];
		_entity setVariable ["SSS_needConfirmation",false,true];
		_entity setVariable ["SSS_signalApproved",false,true];
		_entity setVariable ["SSS_deniedSignals",[],true];
		_entity setVariable ["SSS_slingLoadReady",false,true];
		_entity setVariable ["SSS_slingLoadObject",objNull,true];
		_entity setVariable ["SSS_flyingHeight",80,true];
		_entity setVariable ["SSS_speedMode",1,true];
		_entity setVariable ["SSS_combatMode",0,true];
		_entity setVariable ["SSS_lightsOn",isLightOn _vehicle,true];
		_entity setVariable ["SSS_collisionLightsOn",isCollisionLightOn _vehicle,true];
	};

	case (_vehicle isKindOf "VTOL_Base_F") : {
		BASE_TRAITS(_entity,typeOf _vehicle,_callsign,_side,ICON_VTOL,_customInit,"Transport","transportVTOL",_accessItems,_accessCondition,_requestCondition);
		PHYSICAL_TRAITS(_entity,_vehicle,_group,getPosASL _vehicle,_respawnTime);
		CREATE_TASK_MARKER(_entity,_callsign,"mil_end",LLSTRING(AirTransport));

		// Specifics
		_entity setVariable ["SSS_awayFromBase",false,true];
		_entity setVariable ["SSS_onTask",false,true];
		_entity setVariable ["SSS_interrupt",false,true];
		_entity setVariable ["SSS_needConfirmation",false,true];
		_entity setVariable ["SSS_signalApproved",false,true];
		_entity setVariable ["SSS_deniedSignals",[],true];
		_entity setVariable ["SSS_flyingHeight",250,true];
		_entity setVariable ["SSS_speedMode",1,true];
		_entity setVariable ["SSS_combatMode",0,true];
		_entity setVariable ["SSS_lightsOn",isLightOn _vehicle,true];
		_entity setVariable ["SSS_collisionLightsOn",isCollisionLightOn _vehicle,true];
	};

	case (_vehicle isKindOf "Plane") : {
		BASE_TRAITS(_entity,typeOf _vehicle,_callsign,_side,ICON_PLANE,_customInit,"Transport","transportPlane",_accessItems,_accessCondition,_requestCondition);
		PHYSICAL_TRAITS(_entity,_vehicle,_group,getPosASL _vehicle,_respawnTime);
		CREATE_TASK_MARKER(_entity,_callsign,"mil_end",LLSTRING(AirTransport));

		// Specifics
		[_vehicle,0] remoteExecCall ["setFuel",owner _vehicle];
		_entity setVariable ["SSS_awayFromBase",false,true];
		_entity setVariable ["SSS_onTask",false,true];
		_entity setVariable ["SSS_interrupt",false,true];
		_entity setVariable ["SSS_flyingHeight",500,true];
		_entity setVariable ["SSS_speedMode",1,true];
		_entity setVariable ["SSS_combatMode",0,true];
		_entity setVariable ["SSS_lightsOn",isLightOn _vehicle,true];
		_entity setVariable ["SSS_collisionLightsOn",isCollisionLightOn _vehicle,true];
	};

	case (_vehicle isKindOf "Ship") : {
		BASE_TRAITS(_entity,typeOf _vehicle,_callsign,_side,ICON_BOAT,_customInit,"Transport","transportMaritime",_accessItems,_accessCondition,_requestCondition);
		PHYSICAL_TRAITS(_entity,_vehicle,_group,getPosASL _vehicle,_respawnTime);
		CREATE_TASK_MARKER(_entity,_callsign,"mil_end",LLSTRING(SeaTransport));

		// Specifics
		_entity setVariable ["SSS_awayFromBase",false,true];
		_entity setVariable ["SSS_onTask",false,true];
		_entity setVariable ["SSS_interrupt",false,true];
		_entity setVariable ["SSS_speedMode",2,true];
		_entity setVariable ["SSS_combatMode",0,true];
		_entity setVariable ["SSS_lightsOn",isLightOn _vehicle,true];
		_entity setVariable ["SSS_collisionLightsOn",isCollisionLightOn _vehicle,true];
	};

	case (_vehicle isKindOf "LandVehicle") : {
		BASE_TRAITS(_entity,typeOf _vehicle,_callsign,_side,ICON_CAR,_customInit,"Transport","transportLandVehicle",_accessItems,_accessCondition,_requestCondition);
		PHYSICAL_TRAITS(_entity,_vehicle,_group,getPosASL _vehicle,_respawnTime);
		CREATE_TASK_MARKER(_entity,_callsign,"mil_end",LLSTRING(LandTransport));

		// Specifics
		_entity setVariable ["SSS_awayFromBase",false,true];
		_entity setVariable ["SSS_onTask",false,true];
		_entity setVariable ["SSS_interrupt",false,true];
		_entity setVariable ["SSS_speedMode",2,true];
		_entity setVariable ["SSS_combatMode",0,true];
		_entity setVariable ["SSS_lightsOn",isLightOn _vehicle,true];
	};
};

// Assignment
SSS_entities pushBack _entity;
publicVariable "SSS_entities";

// Event handlers
[_entity,"Deleted",{_this call EFUNC(common,deletedEntity)}] call CBA_fnc_addBISEventHandler;
[_vehicle,"Deleted",{_this call EFUNC(common,deletedVehicle)}] call CBA_fnc_addBISEventHandler;
[_vehicle,"Killed",{(_this # 0) call EFUNC(common,respawn)}] remoteExecCall ["CBA_fnc_addBISEventHandler",0];
[driver _vehicle,"Killed",{vehicle (_this # 0) call EFUNC(common,respawn)}] remoteExecCall ["CBA_fnc_addBISEventHandler",0];
[_vehicle,"GetOut",{
	params ["_vehicle","_role"];

	if (_role == "driver") then {
		_vehicle removeEventHandler [_thisType,_thisID];
		_vehicle call EFUNC(common,respawn);
	};
}] call CBA_fnc_addBISEventHandler;

// Commission vehicle
[_entity,_vehicle] call EFUNC(common,commission);
(group driver _vehicle) setVariable ["acex_headless_blacklist",true,true];

// Execute custom code
_vehicle call _customInit;

_entity

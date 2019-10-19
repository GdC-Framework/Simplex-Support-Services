#include "script_component.hpp"

params ["_vehicle","_player"];

if (!alive _vehicle || !alive driver _vehicle) exitWith {false};

private _entity = _vehicle getVariable ["SSS_parentEntity",objNull];

if (isNull _entity || {!(_entity in ([_player,"transport"] call FUNC(availableEntities)))}) exitWith {false};

private _showSupport = switch (_entity getVariable "SSS_supportType") do {
	case "transportHelicopter" : {SSS_showTransportHelicopters};
	case "transportLandVehicle" : {SSS_showTransportLandVehicles};
	case "transportMaritime" : {SSS_showTransportMaritime};
	case "transportPlane" : {SSS_showTransportPlanes};
	case "transportVTOL" : {SSS_showTransportVTOLs};
	default {false};
};

SSS_showTransport && _showSupport

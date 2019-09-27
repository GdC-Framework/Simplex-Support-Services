#include "script_component.hpp"

params [["_entity",objNull,[objNull]],["_request",0,[0]],["_position",[],[[]]],["_extraParams",[],[[]]]];

if (isNull _entity) exitWith {};

private _vehicle = _entity getVariable ["SSS_vehicle",objNull];

if (!alive _vehicle) exitWith {};

if (isNil {(group _vehicle) getVariable "SSS_protectWaypoints"}) exitWith {
	_vehicle call EFUNC(common,respawn);
};

if (!local _vehicle) exitWith {
	_this remoteExecCall [QFUNC(requestTransportMaritime),_vehicle];
};

switch (_request) do {
	// RTB
	case 0 : {
		if !(_entity getVariable "SSS_awayFromBase") exitWith {};

		INTERRUPT(_entity,_vehicle);

		[{!((_this # 0) getVariable "SSS_onTask")},{
			params ["_entity","_vehicle"];

			private _position = ASLtoAGL (_entity getVariable "SSS_base");

			// Begin order
			_entity setVariable ["SSS_onTask",true,true];
			[_entity,true,_position] call EFUNC(common,updateMarker);
			NOTIFY(_entity,"Returning to base.");

			_vehicle setVariable ["SSS_WPDone",false];
			[_entity,_vehicle] call EFUNC(common,clearWaypoints);
			[_vehicle,_position,0,"MOVE","","","","",WP_DONE] call EFUNC(common,addWaypoint);

			[{WAIT_UNTIL_WPDONE},{
				params ["_entity","_vehicle"];

				if (CANCEL_CONDITION) exitWith {
					CANCEL_ORDER(_entity,"RTB");
				};

				END_ORDER(_entity,"Arrived at base. Ready for further tasking.");
				_entity setVariable ["SSS_awayFromBase",false,true];
				_vehicle engineOn false;
				_vehicle doFollow _vehicle;

				[_entity,_vehicle] call EFUNC(common,resetOnRTB);

				["SSS_requestCompleted",[_entity,["RTB"]]] call CBA_fnc_globalEvent;
			},[_entity,_vehicle]] call CBA_fnc_waitUntilAndExecute;
		},[_entity,_vehicle]] call CBA_fnc_waitUntilAndExecute;
	};
	// Move
	case 1;
	case 2 : {
		private _engineOn = _request isEqualTo 2;

		INTERRUPT(_entity,_vehicle);

		[{!((_this # 0) getVariable "SSS_onTask")},{
			params ["_entity","_vehicle","_position","_engineOn"];

			BEGIN_ORDER(_entity,_position,"Moving to requested location.");

			_vehicle setVariable ["SSS_WPDone",false];
			[_entity,_vehicle] call EFUNC(common,clearWaypoints);
			[_vehicle,_position,0,"MOVE","","","","",WP_DONE] call EFUNC(common,addWaypoint);

			[{WAIT_UNTIL_WPDONE},{
				params ["_entity","_vehicle"];

				if (CANCEL_CONDITION) exitWith {
					CANCEL_ORDER(_entity,"Move");
				};

				END_ORDER(_entity,"Destination reached. Ready for further tasking.");

				private _requestName = if (!_engineOn) then {
					_vehicle engineOn false;
					"MOVE_ENG_OFF"
				} else {"MOVE"};
				
				["SSS_requestCompleted",[_entity,[_requestName]]] call CBA_fnc_globalEvent;
			},[_entity,_vehicle,_engineOn]] call CBA_fnc_waitUntilAndExecute;
		},[_entity,_vehicle,_position,_engineOn]] call CBA_fnc_waitUntilAndExecute;
	};
};
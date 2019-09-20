classdef MAIN < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        OysterWaveConverterBearingVariableOptimiserLabel  matlab.ui.control.Label
        InputVariablesGeneralPanel      matlab.ui.container.Panel
        ExpectedHeaveForcekNEditFieldLabel  matlab.ui.control.Label
        ExpectedHeaveForcekNEditField   matlab.ui.control.NumericEditField
        CoefficientofFrictionLabel      matlab.ui.control.Label
        CoefficientofFrictionEditField  matlab.ui.control.NumericEditField
        SeaTemperatureKEditFieldLabel   matlab.ui.control.Label
        SeaTemperatureKEditField        matlab.ui.control.NumericEditField
        SweptAngleLabel                 matlab.ui.control.Label
        SweptAngleEditField             matlab.ui.control.NumericEditField
        RotationalFrequencyHzEditFieldLabel  matlab.ui.control.Label
        RotationalFrequencyHzEditField  matlab.ui.control.NumericEditField
        InputVariablesMaterialPropetiesPanel  matlab.ui.container.Panel
        Densitykgm3EditFieldLabel       matlab.ui.control.Label
        Densitykgm3EditField            matlab.ui.control.NumericEditField
        ThermalConductivitykWmKEditFieldLabel  matlab.ui.control.Label
        ThermalConductivitykWmKEditField  matlab.ui.control.NumericEditField
        SpecificHeatCpJkgKEditFieldLabel  matlab.ui.control.Label
        SpecificHeatCpJkgKEditField     matlab.ui.control.NumericEditField
        BearingMaterialLabel            matlab.ui.control.Label
        HousingMaterialLabel            matlab.ui.control.Label
        Densitykgm3EditField_2Label     matlab.ui.control.Label
        Densitykgm3EditField_2          matlab.ui.control.NumericEditField
        ThermalConductivitykWmKEditField_2Label  matlab.ui.control.Label
        ThermalConductivitykWmKEditField_2  matlab.ui.control.NumericEditField
        SpecificHeatCpJkgKEditField_2Label  matlab.ui.control.Label
        SpecificHeatCpJkgKEditField_2   matlab.ui.control.NumericEditField
        InputVariablesOperationalDetailsPanel  matlab.ui.container.Panel
        NumberofTemperatureGradientNodesEditFieldLabel  matlab.ui.control.Label
        NumberofTemperatureGradientNodesEditField  matlab.ui.control.NumericEditField
        StoppingTimesEditFieldLabel     matlab.ui.control.Label
        StoppingTimesEditField          matlab.ui.control.NumericEditField
        UIAxes                          matlab.ui.control.UIAxes
        RunOptimisationButton           matlab.ui.control.Button
        OutputPanel                     matlab.ui.container.Panel
        OptimalVolumem3EditFieldLabel   matlab.ui.control.Label
        OptimalVolumem3EditField        matlab.ui.control.NumericEditField
        OptimalLengthmEditFieldLabel    matlab.ui.control.Label
        OptimalLengthmEditField         matlab.ui.control.NumericEditField
        OptimalThicknessmEditFieldLabel  matlab.ui.control.Label
        OptimalThicknessmEditField      matlab.ui.control.NumericEditField
        OptimalRadiusmEditFieldLabel    matlab.ui.control.Label
        OptimalRadiusmEditField         matlab.ui.control.NumericEditField
        STATUSEditFieldLabel            matlab.ui.control.Label
        STATUSEditField                 matlab.ui.control.EditField
        CostofPTFEat26kgEditFieldLabel  matlab.ui.control.Label
        CostofPTFEat26kgEditField       matlab.ui.control.NumericEditField
    end

    methods (Access = private)

        % Button pushed function: RunOptimisationButton
        function RunOptimisationButtonPushed(app, event)
            clc            
            F_heave = app.ExpectedHeaveForcekNEditField.Value;  
            mu = app.CoefficientofFrictionEditField.Value;
            T_sea = app.SeaTemperatureKEditField.Value;
            dtheta_max = app.SweptAngleEditField.Value;
            f_rotation = app.RotationalFrequencyHzEditField.Value;
            n = app.NumberofTemperatureGradientNodesEditField.Value;  
            rho = [app.Densitykgm3EditField.Value, app.Densitykgm3EditField_2.Value];
            k = [app.ThermalConductivitykWmKEditField.Value, app.ThermalConductivitykWmKEditField_2.Value];
            c = [app.SpecificHeatCpJkgKEditField.Value,app.SpecificHeatCpJkgKEditField_2.Value];
            tstop = app.StoppingTimesEditField.Value;
            
            th_bearing=0.03;  
            OptL_bearing = 100; 
            
            app.STATUSEditField.Value = "Processing";
            while OptL_bearing > 5
                th_bearing = th_bearing+0.01;
                [dx,T,tmax,OptL_bearing,Opt_Vol,rad_bearing] = Heatmodel(F_heave,mu,T_sea,dtheta_max,f_rotation,n,rho,k,c,th_bearing,tstop);
                x=(0:n)*dx; 
                plot(app.UIAxes,x,T)
            end
            
            app.OptimalVolumem3EditField.Value = Opt_Vol;
            app.OptimalLengthmEditField.Value = OptL_bearing;
            app.OptimalThicknessmEditField.Value = th_bearing;
            app.OptimalRadiusmEditField.Value = rad_bearing;
            
            Bmass = 1200*Opt_Vol;
            Cost = 2.6*Bmass;
            
            app.CostofPTFEat26kgEditField.Value = Cost;
            

            app.STATUSEditField.Value = "Finished";
        end
    end

    % App initialization and construction
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure
            app.UIFigure = uifigure;
            app.UIFigure.Color = [0.902 0.902 0.902];
            app.UIFigure.Position = [100 100 885 539];
            app.UIFigure.Name = 'UI Figure';
            app.UIFigure.Resize = 'off';

            % Create OysterWaveConverterBearingVariableOptimiserLabel
            app.OysterWaveConverterBearingVariableOptimiserLabel = uilabel(app.UIFigure);
            app.OysterWaveConverterBearingVariableOptimiserLabel.FontSize = 22;
            app.OysterWaveConverterBearingVariableOptimiserLabel.FontAngle = 'italic';
            app.OysterWaveConverterBearingVariableOptimiserLabel.Position = [18 468 239 59];
            app.OysterWaveConverterBearingVariableOptimiserLabel.Text = {'Oyster Wave Converter:'; 'Bearing Variable Optimiser'};

            % Create InputVariablesGeneralPanel
            app.InputVariablesGeneralPanel = uipanel(app.UIFigure);
            app.InputVariablesGeneralPanel.TitlePosition = 'centertop';
            app.InputVariablesGeneralPanel.Title = 'Input Variables: General';
            app.InputVariablesGeneralPanel.FontSize = 18;
            app.InputVariablesGeneralPanel.Position = [14 299 252 156];

            % Create ExpectedHeaveForcekNEditFieldLabel
            app.ExpectedHeaveForcekNEditFieldLabel = uilabel(app.InputVariablesGeneralPanel);
            app.ExpectedHeaveForcekNEditFieldLabel.HorizontalAlignment = 'right';
            app.ExpectedHeaveForcekNEditFieldLabel.Position = [10 98 178 15];
            app.ExpectedHeaveForcekNEditFieldLabel.Text = 'Expected Heave Force (kN)';

            % Create ExpectedHeaveForcekNEditField
            app.ExpectedHeaveForcekNEditField = uieditfield(app.InputVariablesGeneralPanel, 'numeric');
            app.ExpectedHeaveForcekNEditField.Limits = [0 10000000];
            app.ExpectedHeaveForcekNEditField.Position = [195 94 48 22];
            app.ExpectedHeaveForcekNEditField.Value = 2600;

            % Create CoefficientofFrictionLabel
            app.CoefficientofFrictionLabel = uilabel(app.InputVariablesGeneralPanel);
            app.CoefficientofFrictionLabel.HorizontalAlignment = 'right';
            app.CoefficientofFrictionLabel.Position = [27 77 161 15];
            app.CoefficientofFrictionLabel.Text = 'Coefficient of Friction, ?';

            % Create CoefficientofFrictionEditField
            app.CoefficientofFrictionEditField = uieditfield(app.InputVariablesGeneralPanel, 'numeric');
            app.CoefficientofFrictionEditField.Limits = [0 10];
            app.CoefficientofFrictionEditField.Position = [195 73 48 22];
            app.CoefficientofFrictionEditField.Value = 0.07;

            % Create SeaTemperatureKEditFieldLabel
            app.SeaTemperatureKEditFieldLabel = uilabel(app.InputVariablesGeneralPanel);
            app.SeaTemperatureKEditFieldLabel.HorizontalAlignment = 'right';
            app.SeaTemperatureKEditFieldLabel.Position = [39 57 149 15];
            app.SeaTemperatureKEditFieldLabel.Text = 'Sea Temperature (K)';

            % Create SeaTemperatureKEditField
            app.SeaTemperatureKEditField = uieditfield(app.InputVariablesGeneralPanel, 'numeric');
            app.SeaTemperatureKEditField.Limits = [0 Inf];
            app.SeaTemperatureKEditField.Position = [195 53 48 22];
            app.SeaTemperatureKEditField.Value = 283;

            % Create SweptAngleLabel
            app.SweptAngleLabel = uilabel(app.InputVariablesGeneralPanel);
            app.SweptAngleLabel.HorizontalAlignment = 'right';
            app.SweptAngleLabel.Position = [17 36 171 15];
            app.SweptAngleLabel.Text = 'Swept Angle (?)';

            % Create SweptAngleEditField
            app.SweptAngleEditField = uieditfield(app.InputVariablesGeneralPanel, 'numeric');
            app.SweptAngleEditField.Limits = [1 180];
            app.SweptAngleEditField.Position = [195 32 48 22];
            app.SweptAngleEditField.Value = 46;

            % Create RotationalFrequencyHzEditFieldLabel
            app.RotationalFrequencyHzEditFieldLabel = uilabel(app.InputVariablesGeneralPanel);
            app.RotationalFrequencyHzEditFieldLabel.HorizontalAlignment = 'right';
            app.RotationalFrequencyHzEditFieldLabel.Position = [17 15 171 15];
            app.RotationalFrequencyHzEditFieldLabel.Text = 'Rotational Frequency (Hz)';

            % Create RotationalFrequencyHzEditField
            app.RotationalFrequencyHzEditField = uieditfield(app.InputVariablesGeneralPanel, 'numeric');
            app.RotationalFrequencyHzEditField.Limits = [0 100];
            app.RotationalFrequencyHzEditField.Position = [195 11 48 22];
            app.RotationalFrequencyHzEditField.Value = 1.3;

            % Create InputVariablesMaterialPropetiesPanel
            app.InputVariablesMaterialPropetiesPanel = uipanel(app.UIFigure);
            app.InputVariablesMaterialPropetiesPanel.TitlePosition = 'centertop';
            app.InputVariablesMaterialPropetiesPanel.Title = 'Input Variables: Material Propeties';
            app.InputVariablesMaterialPropetiesPanel.FontSize = 18;
            app.InputVariablesMaterialPropetiesPanel.Position = [14 9 252 283];

            % Create Densitykgm3EditFieldLabel
            app.Densitykgm3EditFieldLabel = uilabel(app.InputVariablesMaterialPropetiesPanel);
            app.Densitykgm3EditFieldLabel.HorizontalAlignment = 'right';
            app.Densitykgm3EditFieldLabel.Position = [52 177 136 15];
            app.Densitykgm3EditFieldLabel.Text = 'Density, ? (kg/m^3)';

            % Create Densitykgm3EditField
            app.Densitykgm3EditField = uieditfield(app.InputVariablesMaterialPropetiesPanel, 'numeric');
            app.Densitykgm3EditField.Position = [195 173 48 22];
            app.Densitykgm3EditField.Value = 1200;

            % Create ThermalConductivitykWmKEditFieldLabel
            app.ThermalConductivitykWmKEditFieldLabel = uilabel(app.InputVariablesMaterialPropetiesPanel);
            app.ThermalConductivitykWmKEditFieldLabel.HorizontalAlignment = 'right';
            app.ThermalConductivitykWmKEditFieldLabel.Position = [27 198 161 15];
            app.ThermalConductivitykWmKEditFieldLabel.Text = 'Thermal Conductivity, k (W/mK)';

            % Create ThermalConductivitykWmKEditField
            app.ThermalConductivitykWmKEditField = uieditfield(app.InputVariablesMaterialPropetiesPanel, 'numeric');
            app.ThermalConductivitykWmKEditField.Position = [195 194 48 22];
            app.ThermalConductivitykWmKEditField.Value = 0.2;

            % Create SpecificHeatCpJkgKEditFieldLabel
            app.SpecificHeatCpJkgKEditFieldLabel = uilabel(app.InputVariablesMaterialPropetiesPanel);
            app.SpecificHeatCpJkgKEditFieldLabel.HorizontalAlignment = 'right';
            app.SpecificHeatCpJkgKEditFieldLabel.Position = [17 156 171 15];
            app.SpecificHeatCpJkgKEditFieldLabel.Text = 'Specific Heat, Cp (J/kgK)';

            % Create SpecificHeatCpJkgKEditField
            app.SpecificHeatCpJkgKEditField = uieditfield(app.InputVariablesMaterialPropetiesPanel, 'numeric');
            app.SpecificHeatCpJkgKEditField.Position = [195 152 48 22];
            app.SpecificHeatCpJkgKEditField.Value = 1200;

            % Create BearingMaterialLabel
            app.BearingMaterialLabel = uilabel(app.InputVariablesMaterialPropetiesPanel);
            app.BearingMaterialLabel.HorizontalAlignment = 'center';
            app.BearingMaterialLabel.FontSize = 16;
            app.BearingMaterialLabel.FontWeight = 'bold';
            app.BearingMaterialLabel.FontAngle = 'italic';
            app.BearingMaterialLabel.Position = [73 227 108 20];
            app.BearingMaterialLabel.Text = 'Bearing Material';

            % Create HousingMaterialLabel
            app.HousingMaterialLabel = uilabel(app.InputVariablesMaterialPropetiesPanel);
            app.HousingMaterialLabel.HorizontalAlignment = 'center';
            app.HousingMaterialLabel.FontSize = 16;
            app.HousingMaterialLabel.FontWeight = 'bold';
            app.HousingMaterialLabel.FontAngle = 'italic';
            app.HousingMaterialLabel.Position = [72 85 111 20];
            app.HousingMaterialLabel.Text = 'Housing Material';

            % Create Densitykgm3EditField_2Label
            app.Densitykgm3EditField_2Label = uilabel(app.InputVariablesMaterialPropetiesPanel);
            app.Densitykgm3EditField_2Label.HorizontalAlignment = 'right';
            app.Densitykgm3EditField_2Label.Position = [23 35 165 15];
            app.Densitykgm3EditField_2Label.Text = 'Density, ? (kg/m^3)';

            % Create Densitykgm3EditField_2
            app.Densitykgm3EditField_2 = uieditfield(app.InputVariablesMaterialPropetiesPanel, 'numeric');
            app.Densitykgm3EditField_2.Position = [195 31 48 22];
            app.Densitykgm3EditField_2.Value = 7800;

            % Create ThermalConductivitykWmKEditField_2Label
            app.ThermalConductivitykWmKEditField_2Label = uilabel(app.InputVariablesMaterialPropetiesPanel);
            app.ThermalConductivitykWmKEditField_2Label.HorizontalAlignment = 'right';
            app.ThermalConductivitykWmKEditField_2Label.Position = [23 56 165 15];
            app.ThermalConductivitykWmKEditField_2Label.Text = 'Thermal Conductivity, k (W/mK)';

            % Create ThermalConductivitykWmKEditField_2
            app.ThermalConductivitykWmKEditField_2 = uieditfield(app.InputVariablesMaterialPropetiesPanel, 'numeric');
            app.ThermalConductivitykWmKEditField_2.Position = [195 52 48 22];
            app.ThermalConductivitykWmKEditField_2.Value = 45;

            % Create SpecificHeatCpJkgKEditField_2Label
            app.SpecificHeatCpJkgKEditField_2Label = uilabel(app.InputVariablesMaterialPropetiesPanel);
            app.SpecificHeatCpJkgKEditField_2Label.HorizontalAlignment = 'right';
            app.SpecificHeatCpJkgKEditField_2Label.Position = [17 14 171 15];
            app.SpecificHeatCpJkgKEditField_2Label.Text = 'Specific Heat, Cp (J/kgK)';

            % Create SpecificHeatCpJkgKEditField_2
            app.SpecificHeatCpJkgKEditField_2 = uieditfield(app.InputVariablesMaterialPropetiesPanel, 'numeric');
            app.SpecificHeatCpJkgKEditField_2.Position = [195 10 48 22];
            app.SpecificHeatCpJkgKEditField_2.Value = 460;

            % Create InputVariablesOperationalDetailsPanel
            app.InputVariablesOperationalDetailsPanel = uipanel(app.UIFigure);
            app.InputVariablesOperationalDetailsPanel.TitlePosition = 'centertop';
            app.InputVariablesOperationalDetailsPanel.Title = 'Input Variables: Operational Details';
            app.InputVariablesOperationalDetailsPanel.FontSize = 18;
            app.InputVariablesOperationalDetailsPanel.Position = [274 345 320 110];

            % Create NumberofTemperatureGradientNodesEditFieldLabel
            app.NumberofTemperatureGradientNodesEditFieldLabel = uilabel(app.InputVariablesOperationalDetailsPanel);
            app.NumberofTemperatureGradientNodesEditFieldLabel.HorizontalAlignment = 'right';
            app.NumberofTemperatureGradientNodesEditFieldLabel.Position = [12 53 182 15];
            app.NumberofTemperatureGradientNodesEditFieldLabel.Text = 'Number of Temperature Gradient Nodes';

            % Create NumberofTemperatureGradientNodesEditField
            app.NumberofTemperatureGradientNodesEditField = uieditfield(app.InputVariablesOperationalDetailsPanel, 'numeric');
            app.NumberofTemperatureGradientNodesEditField.Limits = [2 100];
            app.NumberofTemperatureGradientNodesEditField.RoundFractionalValues = 'on';
            app.NumberofTemperatureGradientNodesEditField.Editable = 'off';
            app.NumberofTemperatureGradientNodesEditField.Position = [209 49 100 22];
            app.NumberofTemperatureGradientNodesEditField.Value = 10;

            % Create StoppingTimesEditFieldLabel
            app.StoppingTimesEditFieldLabel = uilabel(app.InputVariablesOperationalDetailsPanel);
            app.StoppingTimesEditFieldLabel.HorizontalAlignment = 'right';
            app.StoppingTimesEditFieldLabel.Position = [111 21 83 15];
            app.StoppingTimesEditFieldLabel.Text = 'Stopping Time (s)';

            % Create StoppingTimesEditField
            app.StoppingTimesEditField = uieditfield(app.InputVariablesOperationalDetailsPanel, 'numeric');
            app.StoppingTimesEditField.Limits = [1 100000];
            app.StoppingTimesEditField.RoundFractionalValues = 'on';
            app.StoppingTimesEditField.Position = [209 17 100 22];
            app.StoppingTimesEditField.Value = 1000;

            % Create UIAxes
            app.UIAxes = uiaxes(app.UIFigure);
            title(app.UIAxes, 'Steady State Optimised Temperature vs Position')
            xlabel(app.UIAxes, 'Position,x(m)')
            ylabel(app.UIAxes, 'Temperature, T(K)')
            app.UIAxes.Box = 'on';
            app.UIAxes.XGrid = 'on';
            app.UIAxes.YGrid = 'on';
            app.UIAxes.Position = [274 9 338 320];

            % Create RunOptimisationButton
            app.RunOptimisationButton = uibutton(app.UIFigure, 'push');
            app.RunOptimisationButton.ButtonPushedFcn = createCallbackFcn(app, @RunOptimisationButtonPushed, true);
            app.RunOptimisationButton.BackgroundColor = [1 1 0];
            app.RunOptimisationButton.FontSize = 18;
            app.RunOptimisationButton.Position = [354 477 179 41];
            app.RunOptimisationButton.Text = 'Run Optimisation';

            % Create OutputPanel
            app.OutputPanel = uipanel(app.UIFigure);
            app.OutputPanel.TitlePosition = 'centertop';
            app.OutputPanel.Title = 'Output';
            app.OutputPanel.BackgroundColor = [0.9412 0.9412 0.9412];
            app.OutputPanel.FontSize = 24;
            app.OutputPanel.Position = [619 9 260 518];

            % Create OptimalVolumem3EditFieldLabel
            app.OptimalVolumem3EditFieldLabel = uilabel(app.OutputPanel);
            app.OptimalVolumem3EditFieldLabel.HorizontalAlignment = 'right';
            app.OptimalVolumem3EditFieldLabel.FontSize = 14;
            app.OptimalVolumem3EditFieldLabel.Position = [21 439 149 18];
            app.OptimalVolumem3EditFieldLabel.Text = 'Optimal Volume, (m^3)';

            % Create OptimalVolumem3EditField
            app.OptimalVolumem3EditField = uieditfield(app.OutputPanel, 'numeric');
            app.OptimalVolumem3EditField.Editable = 'off';
            app.OptimalVolumem3EditField.FontSize = 14;
            app.OptimalVolumem3EditField.Position = [185 438 57 22];

            % Create OptimalLengthmEditFieldLabel
            app.OptimalLengthmEditFieldLabel = uilabel(app.OutputPanel);
            app.OptimalLengthmEditFieldLabel.HorizontalAlignment = 'right';
            app.OptimalLengthmEditFieldLabel.FontSize = 14;
            app.OptimalLengthmEditFieldLabel.Position = [21 375 149 18];
            app.OptimalLengthmEditFieldLabel.Text = 'Optimal Length, (m) ';

            % Create OptimalLengthmEditField
            app.OptimalLengthmEditField = uieditfield(app.OutputPanel, 'numeric');
            app.OptimalLengthmEditField.Editable = 'off';
            app.OptimalLengthmEditField.FontSize = 14;
            app.OptimalLengthmEditField.Position = [185 374 57 22];

            % Create OptimalThicknessmEditFieldLabel
            app.OptimalThicknessmEditFieldLabel = uilabel(app.OutputPanel);
            app.OptimalThicknessmEditFieldLabel.HorizontalAlignment = 'right';
            app.OptimalThicknessmEditFieldLabel.FontSize = 14;
            app.OptimalThicknessmEditFieldLabel.Position = [21 306 149 18];
            app.OptimalThicknessmEditFieldLabel.Text = 'Optimal Thickness (m)';

            % Create OptimalThicknessmEditField
            app.OptimalThicknessmEditField = uieditfield(app.OutputPanel, 'numeric');
            app.OptimalThicknessmEditField.Editable = 'off';
            app.OptimalThicknessmEditField.FontSize = 14;
            app.OptimalThicknessmEditField.Position = [185 305 57 22];

            % Create OptimalRadiusmEditFieldLabel
            app.OptimalRadiusmEditFieldLabel = uilabel(app.OutputPanel);
            app.OptimalRadiusmEditFieldLabel.HorizontalAlignment = 'right';
            app.OptimalRadiusmEditFieldLabel.FontSize = 14;
            app.OptimalRadiusmEditFieldLabel.Position = [21 237 149 18];
            app.OptimalRadiusmEditFieldLabel.Text = 'Optimal Radius (m)';

            % Create OptimalRadiusmEditField
            app.OptimalRadiusmEditField = uieditfield(app.OutputPanel, 'numeric');
            app.OptimalRadiusmEditField.Editable = 'off';
            app.OptimalRadiusmEditField.FontSize = 14;
            app.OptimalRadiusmEditField.Position = [185 236 57 22];

            % Create STATUSEditFieldLabel
            app.STATUSEditFieldLabel = uilabel(app.OutputPanel);
            app.STATUSEditFieldLabel.HorizontalAlignment = 'right';
            app.STATUSEditFieldLabel.Position = [90 18 68 15];
            app.STATUSEditFieldLabel.Text = 'STATUS:';

            % Create STATUSEditField
            app.STATUSEditField = uieditfield(app.OutputPanel, 'text');
            app.STATUSEditField.Editable = 'off';
            app.STATUSEditField.Position = [169 13 83 22];
            app.STATUSEditField.Value = 'Awaiting Input';

            % Create CostofPTFEat26kgEditFieldLabel
            app.CostofPTFEat26kgEditFieldLabel = uilabel(app.OutputPanel);
            app.CostofPTFEat26kgEditFieldLabel.HorizontalAlignment = 'right';
            app.CostofPTFEat26kgEditFieldLabel.FontSize = 14;
            app.CostofPTFEat26kgEditFieldLabel.Position = [12 157 158 18];
            app.CostofPTFEat26kgEditFieldLabel.Text = 'Cost of PTFE at £2.6/kg';

            % Create CostofPTFEat26kgEditField
            app.CostofPTFEat26kgEditField = uieditfield(app.OutputPanel, 'numeric');
            app.CostofPTFEat26kgEditField.ValueDisplayFormat = '£%11.4g';
            app.CostofPTFEat26kgEditField.Editable = 'off';
            app.CostofPTFEat26kgEditField.Position = [185 156 57 22];
        end
    end

    methods (Access = public)

        % Construct app
        function app = MAIN

            % Create and configure components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end
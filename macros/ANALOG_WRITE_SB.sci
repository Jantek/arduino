//
// Scilab ( http://www.scilab.org/ ) - This file is part of Scilab
// Copyright (C) 2011-2011 - DIGITEO - Bruno JOFRET
//
// This file must be used under the terms of the CeCILL.
// This source file is licensed as described in the file COPYING, which
// you should have received as part of this distribution.  The terms
// are also available at
// http://www.cecill.info/licences/Licence_CeCILL_V2-en.txt
//
// Modified 20191015 by TCL-ByteCode for Scilab 6 and multiple cards and supports

function [x, y, typ]=ANALOG_WRITE_SB(job, arg1, arg2)
    x=[];
    y=[];
    typ=[];
    maxboard = 2;
    style = "ANALOG_WRITE_SB;blockWithLabel;"+..
            "verticalLabelPosition=bottom;verticalAlign=top;spacing=-2;align=center;"+..
            "displayedLabel=Analog WRITE<br>Pin %s on board %s"
    select job
    case 'plot' then
        // deprecated
    case 'getinputs' then
        // deprecated
    case 'getoutputs' then
        // deprecated
    case 'getorigin' then
        // deprecated
    case 'set' then
        x=arg1;
        graphics=arg1.graphics;
        exprs=graphics.exprs
        model=arg1.model;

        while %t do
            [ok,num_pin,num_arduino,exprs]=scicos_getvalue(['Arduino Analog Write parameters' ; 'UNO analog PIN are : 3, 5, 6, 9, 10 or 11.'; 'MEGA analog PIN are : 1 to 13 and 44 to 46.'],..
            [gettext('Analog Pin'),gettext('Arduino board number')],list('vec',1,'vec',1), exprs)
            mess=[];

            if ~ok then
                // Cancel
                break;
            end
            if num_arduino > maxboard then
                mess=[mess ;gettext("Only "+string(maxboard)+" can be used with this toolbox version ")];
                ok=%f;
            end
            //pin_analog=[3,5,6,9,10,11];//analog pin OUTPUT on Arduino UNO
            //if  length(find(evstr(num_pin)==pin_analog))==0
            //    mess=[mess ;_("Analog Pin must be 3, 5, 6, 9, 10 or 11.")]
            //    ok = %f
            //end


            if ok then
                // Everything's ok
                model.rpar.objs(1).model.rpar=[num_pin,num_arduino];
                model.rpar.objs(1).graphics.exprs=exprs;
                graphics.exprs = exprs;
                x.model=model;
                x.graphics = graphics;
                x.graphics.style = msprintf(style, exprs')
                break
            else
                message(mess);
            end

        end
    case 'define' then
        diagram=scicos_diagram();
        arduino_comp=ARDUINO_ANALOG_WRITE('define')
        arduino_comp.graphics.pein = 3;
        arduino_comp.graphics.peout = 3;
        arduino_comp.graphics.pin = 4;
        input_port=IN_f('define')
        input_port.graphics.exprs=["1"]
        input_port.model.ipar=[1]
        input_port.graphics.pout=4;

        diagram.objs(1)=arduino_comp;
        diagram.objs(2)=input_port;
        diagram.objs(3)=scicos_link(xx=[0 ; 0],yy=[0 ; 0], ct=[5, -1], from=[1, 1,0], to=[1, 1,1])
        diagram.objs(4)=scicos_link(xx=[0 ; 0],yy=[0 ; 0], ct=[1,1], from=[2, 1,0], to=[1, 1,1])

        model=scicos_model();
        model.sim='csuper'
        model.blocktype='h';
        model.dep_ut=[%f %f];
        model.rpar=diagram
        model.in=-1
        model.in2=-2
        model.intyp=-1
        Pin=3; num_arduino=1;
        x=standard_define([2 2],model,[],[]);
        x.graphics.in_implicit=['E'];
        tmp =[string(Pin),string(num_arduino)]
        x.graphics.style = msprintf(style, tmp)
        x.graphics.exprs=tmp;
    end
endfunction

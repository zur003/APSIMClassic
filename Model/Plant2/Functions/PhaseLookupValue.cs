using System;
using System.Collections.Generic;
using System.Text;


public class PhaseLookupValue : Function
{
    [Link]
    Plant P = null;

    [Link]
    Phenology Phenology = null;

    [Link]
    ModelEnvironment ModelEnvironment = null;

    [Param]
    private string Start = "";

    [Param]
    private string End = "";

    public override double Value
    {
        get
        {
            if (Start == "")
                throw new Exception("Phase start name not set:" + Name);
            if (End == "")
                throw new Exception("Phase end name not set:" + Name);

            string[] ChildNames = ModelEnvironment.ChildModelNames();
            if (Phenology.Between(Start, End) && ChildNames.Length > 0)
            {
                Function Lookup = ModelEnvironment.ModelByName(ChildNames[0]) as Function;
                return Lookup.Value;
            }
            else
                return 0.0;
        }
    }
    public override string ValueString
    {
        get
        {
            if (Start == "")
                throw new Exception("Phase start name not set:" + Name);
            if (End == "")
                throw new Exception("Phase end name not set:" + Name);

            string[] ChildNames = ModelEnvironment.ChildModelNames();
            if (Phenology.Between(Start, End) && ChildNames.Length > 0)
            {
                Function Lookup = ModelEnvironment.ModelByName(ChildNames[0]) as Function;
                return Lookup.ValueString;
            }
            else
                return "";
        }
    }
    public bool InPhase
    {
        get
        {
            return Phenology.Between(Start, End);
        }
    }
}
   

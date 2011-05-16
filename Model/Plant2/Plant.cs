using System;
using System.Collections.Generic;
using System.Text;
#if !fulldotnet  
    using ModelFramework;
#endif
using VBMet;
using CSGeneral;

[Model]
public class Plant : Instance
{
    [Link(IsOptional.Yes)]
    Phenology Phenology = null;

    [Link(IsOptional.Yes)]
    Arbitrator Arbitrator = null;

    private List<Organ> _Organs = new List<Organ>();
    public List<Organ> Organs
    {
        // Public property to return our organs to caller. Used primarily for unit testing.
        get { return _Organs; }
    }

    #region Outputs
    [Output("Crop_Type")]
    [Param]
    public string CropType = "";

    [Output]
    private double WaterSupplyDemandRatio = 0;

    [Output]
    public string PlantStatus
    {
        get
        { return "in"; }
    }

    [Output]
    [Units("mm")]
    private double WaterDemand   // Needed for SWIM2
    {
        get
        {
            double Demand = 0;
            foreach (Organ o in Organs)
                Demand += o.WaterDemand;
            return Demand;
        }
    }
    #endregion

    #region Plant functions
    private void DoArbitrator()
    {
        if (Arbitrator != null)
        {
            Arbitrator.DoDM(Organs);
            Arbitrator.DoN(Organs);
        }
    }
    public void DoPotentialGrowth()
    {
        foreach (Organ o in Organs)
            o.DoPotentialGrowth();
    }
    public void DoActualGrowth()
    {
        foreach (Organ o in Organs)
            o.DoActualGrowth();
    }
    private void DoPhenology()
    {
        if (Phenology != null)
            Phenology.DoTimeStep();
    }
    private void DoWater()
    {
        double Supply = 0;
        double Demand = 0;
        foreach (Organ o in Organs)
        {
            Supply += o.WaterSupply;
            Demand += o.WaterDemand;
        }

        if (Demand > 0)
            WaterSupplyDemandRatio = Supply / Demand;
        else
            WaterSupplyDemandRatio = 0;

        double fraction = 1;
        if (Demand > 0)
            fraction = Math.Min(1.0, Supply / Demand);

        foreach (Organ o in Organs)
        {
            if (o.WaterDemand > 0)
                o.WaterAllocation = fraction * o.WaterDemand;
        }

        double FractionUsed = 0;
        if (Supply > 0)
            FractionUsed = Math.Min(1.0, Demand / Supply);

        foreach (Organ o in Organs)
            o.DoWaterUptake(FractionUsed * Supply);
    }
    #endregion

    #region Event handlers and publishers
    [Event]
    public event NewCropDelegate NewCrop;

    [Event]
    public event NullTypeDelegate Sowing;

    [Event]
    public event NullTypeDelegate Cutting;

    [EventHandler]
    public void OnSow(SowPlant2Type Sow)
    {
        // Go through all our children and find all organs.
        foreach (Instance Child in Children)
        {
            if (Child is Organ)
                Organs.Add((Organ)Child);
        }

        if (NewCrop != null)
        {
            NewCropType Crop = new NewCropType();
            Crop.crop_type = CropType;
            Crop.sender = Name;
            NewCrop.Invoke(Crop);
        } 
        
        if (Sowing != null)
            Sowing.Invoke();
    }

    [EventHandler]
    public void OnProcess()
    {
        DoPhenology();
        DoPotentialGrowth();

        DoWater();
        DoArbitrator();
        DoActualGrowth();
    }

    [EventHandler]
    private void OnCut()
    {
        Cutting.Invoke();
    }

    #endregion

}
   

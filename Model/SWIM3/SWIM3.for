! 1) Remove Surface Conductance stuff and replace with constant conductance.
! 2) Remove rainfall energy stuff
! 3) Remove rainfall log and replace with average daily intensity
      Module APSwimModule
      use Registrations
      use infrastructure	  

      character calc_section*(*)
      parameter (calc_section = 'calc')

      character parameters_section*(*)
      parameter (parameters_section = 'parameters')

      character runoff_section*(*)
      parameter (runoff_section = 'runoff')  

      character solute_section*(*)
      parameter (solute_section = 'solute')

      character top_boundary_section*(*)
      parameter (top_boundary_section = 'top_boundary')

      character bottom_boundary_section*(*)
      parameter (bottom_boundary_section = 'bottom_boundary')

      character drain_section*(*)
      parameter (drain_section = 'drain')

      integer M                  ! Maximum number of soil layers
      parameter (M=100)

      integer MV                 ! Maximum number of crops
      parameter (MV=10)

      integer SWIMLogSize
      parameter (SWIMLogSize = 1000)

      integer nsol
      parameter (nsol = 20)

      double precision effpar
      parameter (effpar = 0.184d0)

      double precision psi_ll15
      parameter (psi_ll15 = -15000.d0)

      double precision psiad
      parameter (psiad = -1d6)

      double precision psi0
      parameter (psi0 = -0.6d7)
      !parameter (psi0 = -8d7)

      integer max_table
      parameter (max_table=20)

      integer strsize
      parameter (strsize = 50)


! =====================================================================
!     APSWIM Globals
! =====================================================================
      Type APSwimGlobals
         sequence
         real             swf(0:M)
         real             potet  ! from met file
         real             rain   ! from met file
         double precision mint
         double precision maxt
         double precision radn

         integer          SWIMRainNumPairs
         integer          SWIMEvapNumPairs
         integer          SWIMSolNumPairs(nsol)

         double precision SWIMRainTime (SWIMLogSize)
         double precision SWIMRainAmt (SWIMLogSize)
         double precision SWIMEqRainTime (SWIMLogSize)
         double precision SWIMEqRainAmt (SWIMLogSize)
         double precision SWIMEvapTime (SWIMLogSize)
         double precision SWIMEvapAmt (SWIMLogSize)
         double precision SWIMSolTime (nsol,SWIMLogSize)
         double precision SWIMSolAmt (nsol,SWIMLogSize)
         double precision SubSurfaceInFlow(0:M)

         double precision TD_runoff
         double precision TD_rain
         double precision TD_evap
         double precision TD_pevap
         double precision TD_drain
         logical          subsurface_drain_open         
         double precision TD_subsurface_drain
         double precision TD_soldrain(nsol)
         double precision TD_slssof(nsol)
         double precision TD_wflow(0:M)
         double precision TD_sflow(nsol,0:M)

         double precision t
         double precision dt

         double precision wp
         double precision wp0

         double precision p(0:M)
         double precision psi(0:M)
         double precision th(0:M)
         double precision thold(0:M)
         double precision hk(0:M)
         double precision q(0:M+1)
         double precision h
         double precision hold
         double precision ron
         double precision roff
         double precision res
         double precision resp
         double precision rex
         double precision rssf
         double precision qs(0:M)
         double precision qex(0:M)
         double precision qexpot(0:M)
         double precision qssif(0:M)
         double precision qssof(0:M)


         double precision dc(nsol,M)
         double precision csl(nsol,0:M)
         double precision cslt(nsol,0:M)
         double precision qsl(nsol,0:M+1)
         double precision qsls(nsol,0:M)
         double precision slsur (nsol)
         double precision cslsur (nsol)
         double precision rslon (nsol)
         double precision rsloff (nsol)
         double precision rslex (nsol)

         logical demand_is_met(MV,nsol)

         integer solute_owners (nsol)

         double precision work
         double precision slwork

         double precision hmin
         double precision gsurf

         integer day
         integer year
         double precision apsim_timestep
         integer start_day
         integer start_year
         character apsim_time*10
         logical run_has_started


         double precision psim
         double precision psimin(MV)
         double precision rld(0:M,MV)
         double precision rc(0:M,MV)
         double precision rtp(MV)
         double precision rt(MV)
         double precision ctp(MV)
         double precision ct(MV)
         double precision qr(0:M,MV)
         double precision qrpot(0:M,MV)
         double precision slup(MV,nsol) ! this seems a silly declaration
                                     ! from what I see it makes no difference
                                     ! because it is not used.

         character crop_names (MV)*(strsize)
         character crop_owners (MV)*(strsize)
         integer crop_owner_id (MV)
         logical   crop_in(MV)
         logical demand_received(MV)
         integer num_crops
         integer supply_event_id(MV)  ! Indicates the event number for sending CohortWaterSupply
         
         integer          nveg
         double precision root_radius(0:M,MV)
         double precision root_conductance(0:M,MV)
         double precision pep(MV)
         double precision solute_demand (MV,nsol)
         double precision canopy_height(MV)
         double precision cover_tot(MV)

         double precision crop_cover
         double precision residue_cover
         double precision cover_green_sum
         double precision cover_surface_runoff
         
         double precision qbp
         double precision qbpd
!cnh      double precision slbp0
         double precision qslbp (nsol)

         double precision gf

         double precision swta(M)

         double precision psuptake(nsol,MV,0:M)
         double precision pwuptake(MV,0:M)
         double precision pwuptakepot(MV,0:M)
         double precision cslold(nsol,0:M)
         double precision cslstart(nsol,0:M)


         logical crops_found
         double precision psix(MV)
         
         double precision CN_runoff
         double precision DELk(0:M,4)
         double precision Mk(0:M,4)         
         double precision m0(0:M,5),M1(0:M,5),Y0(0:M,5),Y1(0:M,5)
         double precision MicroP(0:M),MicroKs(0:M),Kdula(0:M)
         double precision MacroP(0:M)
      End Type APSwimGlobals
! =====================================================================
!     APSWIM Parameters
! =====================================================================
      Type APSwimParameters
         sequence
         character        evap_source*50
         character        echo_directives*5
         logical          diagnostics
         double precision salb

         double precision dlayer(0:M)
         double precision ll15(0:M),DUL(0:M),SAT(0:M),Ks(0:M)
         double precision air_dry(0:M)
         
         double precision Kdul
         double precision Psidul
         double precision P(0:M),c(0:M),k(0:M)
         double precision psid(0:M)

         logical          ivap
         integer          isbc
         integer          itbc
         integer          ibbc

         character        solute_names (nsol)*(strsize)
         integer          num_solutes

         double precision dw
         double precision dtmin
         double precision dtmax

         double precision swt
         double precision slswt

         double precision hm0
         double precision hm1
         double precision hrc
         double precision roff0
         double precision roff1
         double precision g0
         double precision g1
         double precision grc

         double precision dis
         double precision ex(nsol,0:M)
         double precision cslgw(nsol)
         double precision slupf (nsol)
         double precision slsci (nsol)
         double precision slscr (nsol)
         double precision dcon (nsol)
         double precision a
         double precision dthc 
         double precision dthp 
         double precision disp
         double precision fip(nsol,0:M)

         double precision bbc_value
         double precision water_table_conductance

         double precision init_psi  (0:M)
         double precision rhob(0:M)
         double precision exco(nsol,0:M)

         integer          n
         double precision x(0:M)
         double precision dx(0:M)

         character subsurface_drain*3
         double precision drain_depth
         double precision drain_spacing
         double precision Klat
         double precision drain_radius
         double precision imperm_depth


         double precision cn2_bare
         double precision cn_red
         double precision cn_cov

      End Type APSwimParameters
! =====================================================================
!     APSWIM Constants
! =====================================================================
      Type APSwimConstants
         sequence
         double precision lb_solute, ub_solute

         double precision min_crit_temp
         double precision max_crit_temp
         double precision max_albedo
         double precision residue_albedo

         double precision a_to_evap_fact
         double precision canopy_eos_coef

         character        cover_effects*5

         double precision canopy_fact(max_table)              ! canopy factors for cover runoff effect ()
         double precision canopy_fact_height(max_table)       ! heights for canopy factors (mm)
         double precision canopy_fact_default                  ! default canopy factor in absence of height ()
         integer   num_canopy_fact                    ! number of canopy factors read ()

         double precision negative_conc_warn
         double precision negative_conc_fatal

         integer          max_iterations
         double precision ersoil
         double precision ernode
         double precision errex
         double precision dppl
         double precision dpnl
         double precision slcerr


         double precision min_total_root_length
         character        crop_table_name (MV)*(strsize)
         double precision crop_table_psimin(MV)
         double precision crop_table_root_radius(MV)
         double precision crop_table_root_con(MV)


         character default_rain_time*6   ! default time of rainfall (hh:mm)
         double precision default_rain_duration        ! default duration of rainfall (min)
         character default_evap_time*6   ! default time of evaporation (hh:mm)
         double precision default_evap_duration        ! default duration of evaporation (min)

         double precision  hydrol_effective_depth

         double precision slos (nsol)
         double precision d0 (nsol)
         
      End Type APSwimConstants

      ! instance variables.
      common /InstancePointers/ ID,g,p,c
      save InstancePointers
      type (APSwimGlobals),pointer :: g
      type (APSwimParameters),pointer :: p
      type (APSwimConstants),pointer :: c
      type (IDsType),pointer :: id

! =====================================================================

      contains

* ====================================================================
       subroutine apswim_Init ()
* ====================================================================

      implicit none

*+  Purpose
*      Initialise apswim module

*+  Local Variables
       character Event_string*40       ! String to output
       integer   iost                  ! IOSTAT variable

*- Implementation Section ----------------------------------

      call apswim_zero_variables ()

      call apswim_get_other_variables ()

      ! set swim defaults - params that are not to be set by user
      call apswim_init_defaults ()
      
      ! Get all constants from constants file
      call apswim_read_constants ()
     
      ! Get all parameters from parameter file
      call apswim_read_param ()

      call apswim_read_solute_params()

      call apswim_register_solute_outputs()
      
      ! calculate anything swim needs from input parameters      
      call apswim_init_calc ()

      ! check all inputs for errors
      call apswim_check_inputs()

      ! initialise solute information
      !call apswim_init_solute()

      call apswim_New_Profile_Event()

      return
      end subroutine

* ====================================================================
       subroutine apswim_Reset ()
* ====================================================================

      implicit none

*+  Purpose
*      Initialise apswim module

*+  Local Variables
       character Event_string*40       ! String to output
       integer   iost                  ! IOSTAT variable

*- Implementation Section ----------------------------------

      !call apswim_zero_variables ()

      !call apswim_get_other_variables ()

      ! set swim defaults - params that are not to be set by user
      !call apswim_init_defaults ()
      
      ! Get all constants from constants file
      !call apswim_read_constants ()
     
      ! Get all parameters from parameter file
      call apswim_read_param ()

      !call apswim_read_solute_params()

      !call apswim_register_solute_outputs()
      
      ! calculate anything swim needs from input parameters      
      call apswim_init_calc ()

      ! check all inputs for errors
      !call apswim_check_inputs()

      ! initialise solute information
      !call apswim_init_solute()

      !call apswim_New_Profile_Event()

      return
      end subroutine


* ====================================================================
       subroutine apswim_read_param ()
* ====================================================================

      implicit none

*+  Purpose
*      Read in all parameters from parameter file.

*+  Local Variables
       integer node                    ! node counter variable
       integer num_nodes               ! number of specified nodes
       integer numvals                 ! number of values read from file
       integer num_sl
       integer num_psi
       integer num_theta
       integer point
       character bbc_switch*10
       double precision temp
       
*- Implementation Section ----------------------------------

         ! ------------- Initial Soil Profile Info ---------------

         ! Read in water content as either volumetric content or
         !                matric potential.

      call Read_double_array_optional (
     :              parameters_section,
     :              'theta',
     :              M+1,
     :              '(cm^3/cm^3)',
     :              g%th(0),
     :              num_theta,
     :              1.0d-3,
     :              1.0d0)

      call Read_double_array_optional (
     :              parameters_section,
     :              'psi',
     :              M+1,
     :              '(cm)',
     :              g%psi(0),
     :              num_psi,
     :              -1.0d6,
     :               1.0d2)

      if ((num_theta.gt.0).and.(num_psi.gt.0))then
         call fatal_error (Err_User,
     :      'Both psi and Theta have been supplied by user.')

      else if ((num_theta.eq.0).and.(num_psi.eq.0)) then
         call fatal_error (Err_User,
     :      ' Neither psi or Theta have been supplied by user.')
      else
         ! one of the two has been supplied - OK
      endif


         ! ---------------- Configuration Information --------------

         ! Read in bottom boundary conditions flag from parameter file
         ! -----------------------------------------------------------
cnh Try and use context in model parameterisation to determine the BBC
cnh and its required parameters
c      call Read_char_var (
c     :              parameters_section,
c     :              'bottom_boundary_condition',
c     :              '()',
c     :              bbc_switch,
c     :              numvals)
c      if (bbc_switch.eq.'gradient') then
c         p%ibbc = 0
c      elseif (bbc_switch.eq.'watertable') then
c         p%ibbc = 1
c      elseif (bbc_switch.eq.'zeroflux') then
c         p%ibbc = 2
c      elseif (bbc_switch.eq.'seepage') then
c         p%ibbc = 3
c      else
c         call fatal_error (ERR_User,
c     :         'Bad Bottom boundary condition switch.')
c      endif

         call Read_double_var_optional (
     :              parameters_section,
     :              'watertabledepth',
     :              '()',
     :              temp,
     :              numvals,
     :              -10d6,
     :               10d6)
       if (numvals.gt.0) then
         p%ibbc = 1
         p%bbc_value = temp

c         call Read_double_var (
c     :              parameters_section,
c     :              'watertableconductance',
c     :              '(/h)',
c     :              p%water_table_conductance,
c     :              numvals,
c     :             0d0,
c     :              1d0)

       else
          ! Assume constant gradient BBC
          p%ibbc = 0
          p%bbc_value = 0d0
       endif
      

         ! Read in vapour conductivity flag from parameter file
         ! ----------------------------------------------------
      call Read_logical_var (
     :              parameters_section,
     :              'vapour_conductivity',
     :              '(??)',
     :              p%ivap,
     :              numvals)

      ! Read in flag for echoing incoming messages
      call Read_char_var_optional (
     :              parameters_section,
     :              'echo_directives',
     :              '(??)',
     :              p%echo_directives,
     :              numvals)
     
      call Read_logical_var_optional (
     :              parameters_section,
     :              'diagnostics',
     :              '()',
     :              p%diagnostics,
     :              numvals)

            call Read_double_array (
     :              parameters_section,
     :              'dlayer',
     :              M+1,
     :              '(mm)',
     :              p%dlayer(0),
     :              numvals,
     :              0.0d0,
     :              1.0d3)
            p%n = numvals - 1

            call Read_double_array (
     :              parameters_section,
     :              'air_dry',
     :              M+1,
     :              '(cm^3/cm^3)',
     :              p%air_dry(0),
     :              numvals,  ! get number of nodes from here
     :              0.0d0,
     :              1.0d0)

            call Read_double_array (
     :              parameters_section,
     :              'll15',
     :              M+1,
     :              '(cm^3/cm^3)',
     :              p%ll15(0),
     :              numvals,  ! get number of nodes from here
     :              0.0d0,
     :              1.0d0)
            call Read_double_array (
     :              parameters_section,
     :              'dul',
     :              M+1,
     :              '(cm^3/cm^3)',
     :              p%dul(0),
     :              numvals,  ! get number of nodes from here
     :              0.0d0,
     :              1.0d0)
            call Read_double_array (
     :              parameters_section,
     :              'sat',
     :              M+1,
     :              '(cm^3/cm^3)',
     :              p%sat(0),
     :              numvals,  ! get number of nodes from here
     :              0.0d0,
     :              1.0d0)
            call Read_double_array (
     :              parameters_section,
     :              'ks',
     :              M+1,
     :              '(mm/d)',
     :              p%ks(0),
     :              numvals,  ! get number of nodes from here
     :              0.0d0,
     :              1.0d3)

            call Read_double_var (
     :              parameters_section,
     :              'kdul',
     :              '(mm/d)',
     :              p%Kdul,
     :              numvals,
     :              0.0d0,
     :              1.d1)  

            call Read_double_var (
     :              parameters_section,
     :              'psidul',
     :              '(cm)',
     :              p%Psidul,
     :              numvals,
     :              -1d3,
     :              0d0)  
     
     
            call Read_double_array (
     :              parameters_section,
     :              'bd',
     :              M+1,
     :              '(g/cm^3)',
     :              p%rhob(0),
     :              numvals,  ! get number of nodes from here
     :              0.0d0,
     :              2.0d0)

         ! ------------- Swim calculation parameters -------------

         ! Read in p%dtmin from parameter file

      call Read_double_var (
     :              parameters_section,
     :              'dtmin',
     :              '(min)',
     :              p%dtmin,
     :              numvals,
     :              0.0d0,
     :              1440.d0)  ! 1440 min = 1 g%day

         ! Read in p%dtmax from parameter file

      call Read_double_var (
     :              parameters_section,
     :              'dtmax',
     :              '(min)',
     :              p%dtmax,
     :              numvals,
     :              0.01d0,
     :              1440.d0)  ! 1440 min = 1 g%day




         ! Read in max water increment from parameter file

      call Read_double_var (
     :              parameters_section,
     :              'max_water_increment',
     :              '(??)',
     :              p%dw,
     :              numvals,
     :              1.0d-3,
     :              1.0d1)

      call Read_double_var(
     :           parameters_section,
     :           'swt',
     :           '()',
     :           p%swt,
     :           numvals,
     :           -1d0,
     :           1d0)

      call Read_double_var(
     :           parameters_section,
     :           'slswt',
     :           '()',
     :           p%slswt,
     :           numvals,
     :           -1d0,
     :           1d0)


         ! ------------------ Climate Information ------------------

      call Read_char_var (
     :              parameters_section,
     :              'evap_source',
     :              '()',
     :              p%evap_source,
     :              numvals)

         ! Read in soil albedo from parameter file

      call Read_double_var (
     :              parameters_section,
     :              'salb',
     :              '(??)',
     :              p%salb,
     :              numvals,
     :              0d0,
     :              1d0)


         call Read_double_var (
     :              parameters_section,
     :              'cn2_bare',
     :              '()',
     :              p%cn2_bare,
     :              numvals,
     :              0d0,
     :              1d2)  

         call Read_double_var (
     :              parameters_section,
     :              'cn_red',
     :              '()',
     :              p%cn_red,
     :              numvals,
     :              0d0,
     :              1d2)  

         call Read_double_var (
     :              parameters_section,
     :              'cn_cov',
     :              '()',
     :              p%cn_cov,
     :              numvals,
     :              0d0,
     :              1d0)       
     
      if (p%isbc.eq.2) then

            ! Read in runoff function parameters from parameter file
            ! ------------------------------------------------------

         call Read_double_var (
     :              runoff_section,
     :              'minimum_surface_storage',
     :              '(mm)',
     :              p%hm0,
     :              numvals,
     :              1.0d-3,
     :              1.0d2)

         call Read_double_var (
     :              runoff_section,
     :              'maximum_surface_storage',
     :              '(mm)',
     :              p%hm1,
     :              numvals,
     :              p%hm0+.01d0,
     :              1.0d3)

         call Read_double_var (
     :              runoff_section,
     :              'initial_surface_storage',
     :              '(mm)',
     :              g%hmin,
     :              numvals,
     :              p%hm0+.005d0,
     :              p%hm1-.005d0)

         call Read_double_var (
     :              runoff_section,
     :              'precipitation_constant',
     :              '(mm)',
     :              p%hrc,
     :              numvals,
     :              1.0d0,
     :              1.0d2)

         call Read_double_var (
     :              runoff_section,
     :              'runoff_rate_factor',
     :              '(mm/mm^p)',
     :              p%roff0,
     :              numvals,
     :              1.d-6,
     :              1.d2)

         call Read_double_var (
     :              runoff_section,
     :              'runoff_rate_power',
     :              '()',
     :              p%roff1,
     :              numvals,
     :              1d-1,
     :              10d0)

      else
      endif

      If (p%itbc.eq.2) then
            ! Read in conductance function parameters
            ! ---------------------------------------

         call Read_double_var (
     :              top_boundary_section,
     :              'minimum_conductance',
     :              '(/h)',
     :              p%g0,
     :              numvals,
     :              1.0d-6,
     :              1.0d2)

         call Read_double_var (
     :              top_boundary_section,
     :              'maximum_conductance',
     :              '(/h)',
     :              p%g1,
     :              numvals,
     :              p%g0,
     :              1.0d6)


         call Read_double_var (
     :              top_boundary_section,
     :              'initial_conductance',
     :              '(/h)',
     :              g%gsurf,
     :              numvals,
     :              p%g0,
     :              p%g1)

         call Read_double_var (
     :              top_boundary_section,
     :              'precipitation_constant',
     :              '(cm)',
     :              p%grc,
     :              numvals,
     :              1.0d0,
     :              1.0d2)

      else
      endif


      ! Subsurface Drainage Parameters
      ! ==============================

      call Read_double_var_optional (
     :              parameters_section,
     :              'draindepth',
     :              '(mm)',
     :              p%drain_depth,
     :              numvals,
     :              1.0d0,
     :              p%x(p%n))

      if (numvals.gt.0) then
         p%subsurface_drain = 'on'
         g%subsurface_drain_open = .true.
                  
         call Read_double_var (
     :              parameters_section,
     :              'drainspacing',
     :              '(mm)',
     :              p%drain_spacing,
     :              numvals,
     :              1.0d0,
     :              1.0d5)

         call Read_double_var (
     :              parameters_section,
     :              'drainradius',
     :              '(mm)',
     :              p%drain_radius,
     :              numvals,
     :              1.0d0,
     :              1.0d3)

         call Read_double_var (
     :              parameters_section,
     :              'impermdepth',
     :              '(mm)',
     :              p%imperm_depth,
     :              numvals,
     :              p%drain_depth,
     :              p%x(p%n))

         call Read_double_var (
     :              parameters_section,
     :              'Klat',
     :              '(mm/d)',
     :              p%Klat,
     :              numvals,
     :              1.0d0,
     :              1.0d4)

      else
         ! Do nothing
          p%subsurface_drain = 'off'
          g%subsurface_drain_open = .false.
      endif

      return
      end subroutine



* ====================================================================
       subroutine apswim_get_other_variables ()
* ====================================================================

      implicit none

*+  Purpose
*      Get the values of variables from other modules

*+  Local Variables
      integer numvals                  ! number of values returned

*- Implementation Section ----------------------------------

      call get_double_var (
     :           unknown_module,
     :           'radn',
     :           '(MJ)',
     :           g%radn,
     :           numvals,
     :           0d0,
     :           50d0)
      call get_double_var (
     :           unknown_module,
     :           'maxt',
     :           '(oC)',
     :           g%maxt,
     :           numvals,
     :           -50d0,
     :           70d0)
      call get_double_var (
     :           unknown_module,
     :           'mint',
     :           '(oC)',
     :           g%mint,
     :           numvals,
     :           -50d0,
     :           50d0)


      return
      end subroutine



* ====================================================================
       subroutine apswim_set_other_variables ()
* ====================================================================

      implicit none

*+  Purpose
*     Update variables owned by other modules.

       double precision start_of_day
       double precision end_of_day
       real daily_rain
       character*10 :: variable_name = 'rain'
       character*10 :: units = '(mm)'

*- Implementation Section ----------------------------------


      return
      end subroutine


* ====================================================================
       subroutine apswim_set_rain_variable ()
* ====================================================================

      implicit none

*+  Purpose
*     Update variables owned by other modules.

       double precision start_of_day
       double precision end_of_day
       real daily_rain
       character*10 :: variable_name = 'rain'
       character*10 :: units = '(mm)'

*- Implementation Section ----------------------------------

      if (g%day > 0) then
         start_of_day = apswim_time (g%year,g%day,
     :                               apswim_time_to_mins(g%apsim_time))
         end_of_day = apswim_time (g%year
     :                            ,g%day
     :                            ,apswim_time_to_mins(g%apsim_time)
     :                                +int(g%apsim_timestep))

         daily_rain = (apswim_crain(end_of_day)-
     :                     apswim_crain(start_of_day))*10d0

         call set_real_var(unknown_module
     :                       , trim(variable_name)
     :                       , trim(units)
     :                       , daily_rain)

      else
      endif

      return
      end subroutine


* ====================================================================
       subroutine apswim_Send_my_variable (Variable_name)
* ====================================================================


      implicit none

*+  Sub-Program Arguments
       character Variable_name*(*)     ! (INPUT) Variable name to search for

*+  Purpose
*      Return the value of one of our variables to caller

*+  Changes
*       29/08/97 NIH check for output unknown solute for 'flow_' and others
*       02/11/99 jngh removed crop_cover

*+  Calls


*+  Local Variables
       double precision conc_water_solute(0:M)
       double precision conc_adsorb_solute(0:M)
       double precision dble_dis(0:M)
       double precision dble_exco(0:M)
       double precision dr              ! timestep rainfall (during g%dt)(mm)
       double precision dummy(0:M)
       double precision dummy1
       double precision dummy2
       double precision dummy3
       double precision eo
       double precision h_mm
       double precision hmin_mm
       integer          solnum          ! solute number
       character        solname*(strsize) ! name of solute
       integer          node       ! node number specifier
       double precision start_of_day
       double precision end_of_day
       double precision daily_rain
       character        uname*(strsize)   ! solute name
       character        ucrop*(strsize)   ! crop name
       logical          uflag      ! uptake flag
       double precision uptake(0:M)
       character        uunits*(strsize)  ! utake units
       double precision flow_array(0:M)
       character        flow_name*(strsize) ! Name of flow
       character        flow_units*(strsize) !
       logical          flow_found
       double precision infiltration
       double precision water_table
       double precision conc_solute_pond
       double precision esw
       character        string*10
       
*- Implementation Section ----------------------------------

      if (Variable_name .eq. 'dlayer') then
         call respond2Get_double_array (
     :            Variable_name,
     :            '(mm)',
     :            p%dlayer(0),
     :            p%n+1)
      else if (Variable_name .eq. 'bd') then
         call respond2Get_double_array (
     :            Variable_name,
     :            '(g/cm^3)',
     :            p%rhob(0),
     :            p%n+1)
      else if (Variable_name .eq. 'ks') then
         call respond2Get_double_array (
     :            Variable_name,
     :            '(mm/d)',
     :            p%Ks(0),
     :            p%n+1)
      else if (Variable_name .eq. 'hyd_cond') then
         do 10 node=0,p%n
            call apswim_interp (
     :            node, 
     :            g%psi(node),
     :            dummy1,
     :            dummy2,
     :            dummy(node),
     :            dummy3)
            dummy(node) = 10*exp(dlog(10d0)*dummy(node))
   10    continue
         call respond2Get_double_array (
     :            Variable_name,
     :            '(mm/h)',
     :            dummy(0),
     :            p%n+1)
      else if (Variable_name .eq. 'sw') then
         call respond2Get_double_array (
     :            Variable_name,
     :            '(cm^3/cm^3)',
     :            g%th(0),
     :            p%n+1)
      else if (Variable_name .eq. 'swf') then
         call respond2Get_real_array (
     :            Variable_name,
     :            '()',
     :            g%swf(0),
     :            p%n+1)
      else if (Variable_name .eq. 'sw_dep') then
         do 11 node=0,p%n
            dummy(node) = g%th(node)*p%dlayer(node)
   11    continue
         call respond2Get_double_array (
     :            Variable_name,
     :            '(mm)',
     :            dummy(0),
     :            p%n+1)

      else if (Variable_name .eq. 'll15') then
         call respond2Get_double_array (
     :            Variable_name,
     :            '(cm^3/cm^3)',
     :            p%LL15(0),
     :            p%n+1)
      else if (Variable_name .eq. 'll15_dep') then
         do 12 node=0,p%n
            dummy(node) = p%LL15(node)*p%dlayer(node)
   12    continue
         call respond2Get_double_array (
     :            Variable_name,
     :            '(mm)',
     :            dummy(0),
     :            p%n+1)
      else if (Variable_name .eq. 'dul') then
         call respond2Get_double_array (
     :            Variable_name,
     :            '(cm^3/cm^3)',
     :            p%DUL(0),
     :            p%n+1)
      else if (Variable_name .eq. 'dul_dep') then
         do 13 node=0,p%n
            dummy(node) = p%DUL(node)*p%dlayer(node)
   13    continue
         call respond2Get_double_array (
     :            Variable_name,
     :            '(mm)',
     :            dummy(0),
     :            p%n+1)
      else if (Variable_name .eq. 'sat') then
         call respond2Get_double_array (
     :            Variable_name,
     :            '(cm^3/cm^3)',
     :            p%SAT(0),
     :            p%n+1)
      else if (Variable_name .eq. 'sat_dep') then
         do 14 node=0,p%n
            dummy(node) = p%SAT(node)*p%dlayer(node)
   14    continue
         call respond2Get_double_array (
     :            Variable_name,
     :            '(mm)',
     :            dummy(0),
     :            p%n+1)

      else if (Variable_name .eq. 'esw') then
         esw = 0d0
         do 15 node=0,p%n
            esw = esw+max(0d0,(g%th(node)-p%ll15(node))*p%dlayer(node))
   15    continue
         call respond2Get_double_var (
     :            Variable_name,
     :            '(mm)',
     :            esw)

      else if (Variable_name .eq. 'wp') then
         call respond2Get_double_var (
     :            Variable_name,
     :            '(mm)',
     :            g%wp)
      else if (Variable_name .eq. 'p') then
         call respond2Get_double_array (
     :            Variable_name,
     :            '()',
     :            g%p(0),
     :            p%n+1)
      else if (Variable_name .eq. 'psi') then

         call respond2Get_double_array (
     :            Variable_name,
     :            '(cm)',
     :            g%psi(0),
     :            p%n+1)

      else if (Variable_name .eq. 'psio') then

         do 17 node=0,p%n
            dummy(node) = g%psi(node)
            do 16 solnum=1,nsol
               dummy(node)=dummy(node)-c%slos(solnum)*g%csl(solnum,node)
   16       continue

   17    continue


         call respond2Get_double_array (
     :            Variable_name,
     :            '(cm)',
     :            dummy(0),
     :            p%n+1)


      else if (Variable_name .eq. 'runoff') then
         call respond2Get_double_var (
     :            Variable_name,
     :            '(mm)',
     :            g%TD_runoff)

      else if (Variable_name .eq. 'cn_runoff') then
         call respond2Get_double_var (
     :            Variable_name,
     :            '(mm)',
     :            g%CN_runoff)

      else if (Variable_name .eq. 'cover_surface_runoff') then
         call respond2Get_double_var (
     :            Variable_name,
     :            '(0-1)',
     :            g%cover_surface_runoff)

      else if (Variable_name .eq. 'infiltration') then

!         infiltration = max(0d0
!     :                     ,g%TD_wflow(0) + g%TD_evap)
         infiltration = g%TD_wflow(0)
         call respond2Get_double_var (
     :            Variable_name,
     :            '(mm)',
     :            infiltration)

      else if (Variable_name .eq. 'es') then
         call respond2Get_double_var (
     :            Variable_name,
     :            '(mm)',
     :            g%TD_evap)
      else if (Variable_name .eq. 'eos') then
         call respond2Get_double_var (
     :            Variable_name,
     :            '(mm)',
     :            g%TD_pevap)

      else if (Variable_name .eq. 'drain') then
         call respond2Get_double_var (
     :            Variable_name,
     :            '(mm)',
     :            g%TD_drain)

      else if ((Variable_name .eq. 'eo').and.
     :         (p%evap_source .ne. 'eo')) then
         start_of_day = apswim_time (g%year,g%day,
     :                               apswim_time_to_mins(g%apsim_time))
         end_of_day = apswim_time (g%year
     :                            ,g%day
     :                            ,apswim_time_to_mins(g%apsim_time)
     :                                +int(g%apsim_timestep))

         eo = (apswim_cevap(end_of_day)-apswim_cevap(start_of_day))*10d0

         call respond2Get_double_var (
     :            Variable_name,
     :            '(mm)',
     :            eo)

      else if (index (Variable_name, 'uptake_water_').eq.1) then
         ucrop = Variable_name(14:)
         call apswim_get_sw_uptake (ucrop, uptake, uflag)
         if (uflag) then
            call respond2Get_double_array (
     :            Variable_name,
     :            '(mm)',
     :            uptake(0),
     :            p%n+1)
         else
            Call Message_Unused()
         endif

      else if (index (Variable_name, 'supply_').eq.1) then
         call split_line (Variable_name(8:),uname,ucrop,'_')
         call apswim_get_supply (ucrop, uname, uptake, uunits,uflag)
         if (uflag) then
            call respond2Get_double_array (
     :            Variable_name,
     :            uunits,
     :            uptake(0),
     :            p%n+1)
         else
            Call Message_Unused()
         endif

      else if (index (Variable_name, 'psix').eq.1) then
            call respond2Get_double_array (
     :            Variable_name,
     :            'cm',
     :            g%psix,
     :            mv)

      else if (index(Variable_name,'leach_').eq.1) then
         solnum = apswim_solute_number (Variable_name(7:))
         if (solnum.ne.0) then
            call respond2Get_double_var (
     :               Variable_name,
     :               '(kg/ha)',
     :               g%TD_soldrain(solnum))
        else
           ! Unknown solute - give no reply
           call Message_Unused ()
        endif

      else if (index(Variable_name,'flow_').eq.1) then
         ! Flow represents flow downward out of a layer
         ! and so start at node 1 (not 0)

         flow_name = Variable_name(len('flow_')+1:)
         call apswim_get_flow (flow_name
     :                        ,flow_array
     :                        ,flow_units
     :                        ,flow_found)
         if (flow_found) then
            call respond2Get_double_array (
     :            Variable_name,
     :            flow_units,
     :            flow_array(1),
     :            p%n+1)
         else
            Call Message_Unused()
         endif

      else if (Variable_name.eq. 'flow') then
         ! Flow represents flow downward out of a layer
         ! and so start at node 1 (not 0)
         call respond2Get_double_array (
     :            Variable_name,
     :            '(mm)',
     :            g%TD_wflow(1),
     :            p%n+1)

      else if (Variable_name .eq. 'salb') then
         call respond2Get_double_var (
     :            Variable_name,
     :            '(0-1)',
     :            p%salb)

      else if (Variable_name .eq. 'hmin') then
         if (p%isbc.eq.2) then
            hmin_mm =g%hmin * 10d0
         else
            hmin_mm = 0.0d0
         endif

         call respond2Get_double_var (
     :            Variable_name,
     :            '(mm)',
     :            hmin_mm)

      else if (Variable_name .eq. 'h'
     :    .OR. variable_name .eq. 'pond') then
         h_mm = g%h * 10.d0
         call respond2Get_double_var (
     :            Variable_name,
     :            '(mm)',
     :            h_mm)

      else if (Variable_name .eq. 'scon') then

         call respond2Get_double_var (
     :            Variable_name,
     :            '(/h)',
     :            g%gsurf)

      else if (Variable_name .eq. 'scon_min') then

         call respond2Get_double_var (
     :            Variable_name,
     :            '(/h)',
     :            p%g0)

      else if (Variable_name .eq. 'scon_max') then

         call respond2Get_double_var (
     :            Variable_name,
     :            '(/h)',
     :            p%g1)

      else if (Variable_name .eq. 'dr') then
         dr=(apswim_crain(g%t) - apswim_crain(g%t-g%dt))*10d0
         call respond2Get_double_var (
     :            Variable_name,
     :            '(mm)',
     :            dr)

      else if (Variable_name .eq. 'dt') then
         call respond2Get_double_var (
     :            Variable_name,
     :            '(min)',
     :            g%dt*60d0)


cnh added as per request by Dr Val Snow

      else if (index(Variable_name,'exco_').eq.1) then

         solnum = apswim_solute_number (Variable_name(6:))
         do 200 node=0,p%n
            dble_exco(node) = p%ex(solnum,node)/p%rhob(node)
  200    continue

         call respond2Get_double_array (
     :            Variable_name,
     :            '()',
     :            dble_exco(0),
     :            p%n+1)

      else if (index(Variable_name,'conc_water_').eq.1) then

         solname = Variable_name(12:)

         call apswim_conc_water_solute (solname, conc_water_solute)

         call respond2Get_double_array (
     :            Variable_name,
     :            '(ug/g)',
     :            conc_water_solute(0),
     :            p%n+1)

      else if (index(Variable_name,'conc_adsorb_').eq.1) then

         solname = Variable_name(13:)

         call apswim_conc_adsorb_solute (solname, conc_adsorb_solute)

         call respond2Get_double_array (
     :            Variable_name,
     :            '(ug/g)',
     :            conc_adsorb_solute(0),
     :            p%n+1)

      else if (Variable_name .eq. 'subsurface_drain') then
         call respond2Get_double_var (
     :            Variable_name,
     :            '(mm)',
     :            g%TD_subsurface_drain)

      else if (Variable_name .eq. 'subsurface_drain_open') then
         if (g%subsurface_drain_open) then
            string = 'true'
         else
            string = 'false'
         endif
         
         call respond2Get_char_var (
     :            Variable_name,
     :            '(-)',
     :            string)     
     
      else if (index(Variable_name,'subsurface_drain_').eq.1) then

         solname = Variable_name(18:)
         solnum = apswim_solute_number(solname)

         if (solnum .ne.0) then
            call respond2Get_double_var (
     :            Variable_name,
     :            '(kg/ha)',
     :            g%TD_slssof(solnum))

         endif

      else if (index(Variable_name,'pond_').eq.1) then
         solname = Variable_name(6:)
         solnum = apswim_solute_number(solname)
         if (solnum .ne.0) then
            conc_solute_pond = g%cslsur(solnum)   ! ug/cc soil
     :                * (g%h*1d8)                 ! cc soil/ha
     :                * 1d-9                      ! kg/ug
            call respond2Get_double_var (
     :            Variable_name,
     :            '(kg/ha)',
     :            conc_solute_pond)
         endif

      else if (Variable_name .eq. 'watertable') then
         water_table = apswim_water_table()
         call respond2Get_double_var (
     :            Variable_name,
     :            '(mm)',
     :            water_table)

      else if (Variable_name .eq. 'work') then
         call respond2Get_double_var (
     :            Variable_name,
     :            '()',
     :            g%work)

      else if (Variable_name .eq. 'swim3') then
         call respond2Get_real_var (
     :            Variable_name,
     :            '(-)',
     :            1.0)


      else
         call Message_Unused ()
      endif

      return
      end subroutine



* ====================================================================
       subroutine apswim_set_my_variable (Variable_name)
* ====================================================================

      implicit none

*+  Sub-Program Arguments
      character Variable_name*(*) ! (INPUT) Variable name to search for

*+  Purpose
*     Set one of our variables altered by some other module

*+  Changes
*      21-06-96 NIH Changed respond2set calls to collect calls

*+  Local Variables
      integer          node
      integer          numvals
      double precision theta(0:M)
      double precision suction(0:M)
      integer solnum
      double precision sol_exco(0:M)  ! solute exchange coefficient
      double precision sol_dis(0:M)   ! solute dispersion coefficient
      character        string*10

*- Implementation Section ----------------------------------

      if (Variable_name .eq. 'sw') then
                       ! dont forget to change type of limits
         call collect_double_array (
     :              'sw',
     :              p%n+1,
     :              '(cm^3/cm^3)',
     :              theta(0),
     :              numvals,
     :              0d0,
     :              1d0)

         call apswim_reset_water_balance (1,theta)

      else if (Variable_name .eq. 'psi') then
                       ! dont forget to change type of limits
         call collect_double_array (
     :              'psi',
     :              p%n+1,
     :              '(cm)',
     :              suction(0),
     :              numvals,
     :              -1.d10,
     :              0.d0)

         call apswim_reset_water_balance (2,suction)

      else if (Variable_name .eq. 'ks') then

         call collect_double_array (
     :              'ks',
     :              p%n+1,
     :              '(mm/d)',
     :              p%Ks(0),
     :              numvals,
     :              0.d0,
     :              1.d4)      
         
         call SetupKCurve()

      else if (Variable_name .eq. 'sat') then

         call collect_double_array (
     :              'sat',
     :              p%n+1,
     :              '(mm/mm)',
     :              p%Sat(0),
     :              numvals,
     :              0.d0,
     :              1.d0)      
         call SetupThetaCurve()
         call SetupKCurve()
         call apswim_reset_water_balance (1,g%th)

      else if (Variable_name .eq. 'dul') then

         call collect_double_array (
     :              'dul',
     :              p%n+1,
     :              '(mm/mm)',
     :              p%DUL(0),
     :              numvals,
     :              0.d0,
     :              1.d0)      
         call SetupThetaCurve()
         call SetupKCurve()
         call apswim_reset_water_balance (1,g%th)

      else if (Variable_name .eq. 'll15') then

         call collect_double_array (
     :              'll15',
     :              p%n+1,
     :              '(mm/mm)',
     :              p%LL15(0),
     :              numvals,
     :              0.d0,
     :              1.d0)      
         call SetupThetaCurve()
         call SetupKCurve()
         call apswim_reset_water_balance (1,g%th)         
         
cnh added as per request by Dr Val Snow

      else if (index(Variable_name,'exco_').eq.1) then

         solnum = apswim_solute_number (Variable_name(6:))
         call collect_double_array (
     :              Variable_name,
     :              p%n+1,
     :              '()',
     :              sol_exco(0),
     :              numvals,
     :              0d0,
     :              15000d0)

         do 300 node=0,numvals-1
            p%ex(solnum,node) = sol_exco(node)*p%rhob(node)
  300    continue

      elseif (Variable_name .eq. 'scon') then
         call collect_double_var (
     :              'scon',
     :              '(/h)',
     :              g%gsurf,
     :              numvals,
     :              0d0,
     :              100d0)
         if ((g%gsurf.gt.p%g1).or.(g%gsurf.lt.p%g0)) then
            call fatal_error (ERR_User,
     :         'Scon set to a value outside of specified decay curve')
         else
            ! it is OK - keep going
         endif

      elseif (Variable_name .eq. 'bbc_potential') then
         call collect_double_var (
     :              Variable_name,
     :              '(cm)',
     :              p%bbc_value,
     :              numvals,
     :              -1d7,
     :              1d7)
         if (p%ibbc.ne.1) then
            p%ibbc = 1
            call Write_string
     :         ('Bottom boundary condition now constant potential')
         endif

      elseif (Variable_name .eq. 'bbc_seepage_potential') then
         call collect_double_var (
     :              Variable_name,
     :              '(cm)',
     :              p%bbc_value,
     :              numvals,
     :              -1d7,
     :              1d7)
         if (p%ibbc.ne.3) then
            p%ibbc = 3
            call Write_string
     :         ('Bottom boundary condition now a seepage potential')
         endif
         
      elseif (Variable_name .eq. 'bbc_gradient') then
         call collect_double_var (
     :              Variable_name,
     :              '(cm)',
     :              p%bbc_value,
     :              numvals,
     :              -1d7,
     :              1d7)
         if (p%ibbc.ne.0) then
            p%ibbc = 0
            call Write_string
     :         ('Bottom boundary condition now constant gradient')
         endif

      elseif (Variable_name .eq. 'subsurface_drain_open') then
         
         call collect_char_var (
     :              Variable_name,
     :              '()',
     :              string,
     :              numvals)
     
         if (string.eq.'true') then
            g%subsurface_drain_open = .true.
            call Write_string
     :         ('Subsurface drain has been opened')
         else
            g%subsurface_drain_open = .false.
            call Write_string
     :         ('Subsurface drain has been closed')
         
         endif
         
      else
         ! Don't know this variable name
         call Message_Unused ()
      endif

      return
      end subroutine

* ====================================================================
       subroutine apswim_zero_variables ()
* ====================================================================

      implicit none

*+  Purpose
*     Set all variables in this module to zero.


*+  Local Variables
       integer counter
       integer node
       integer counter2
       integer vegnum
       integer solnum

*- Implementation Section ----------------------------------

      p%evap_source = ' '
      g%SWIMRainNumPairs = 1
      g%SWIMEvapNumPairs = 1

      do 3 counter = 1, SWIMLogSize
         g%SWIMRainTime(counter)= 0.d0
         g%SWIMRainAmt(counter) = 0.d0
         g%SWIMEqRainTime(counter) = 0.d0
         g%SWIMEqRainAmt(counter) = 0.d0

         g%SWIMEvapTime(counter)= 0.d0
         g%SWIMEvapAmt(counter) = 0.d0

         do 4 solnum = 1,nsol
            g%SWIMSolNumPairs(solnum) = 1
            g%SWIMSolTime(solnum,counter)= 0.d0
            g%SWIMSolAmt(solnum,counter) = 0.d0
    4    continue

    3 continue


      call apswim_reset_daily_totals ()

      do 6 counter = 0,M
         p%air_dry(counter) = 0d0
         p%LL15(counter) = 0d0
         p%DUL(counter) = 0d0
         p%SAT(counter) = 0d0
         p%dlayer(counter) = 0d0
    6 continue
      p%salb = 0.0

      g%run_has_started = .false.

      g%crop_cover = 0.0d0

* =====================================================================
*      common/time/g%t,g%dt,t0,tfin,tcycle
* =====================================================================
c      g%t = 0d0
      g%dt = 0d0
c      t0 = 0d0
c      tfin = 0d0
c      tcycle = 0d0

* =====================================================================
*      common/contrl/pint,p%dw,p%dtmin,p%dtmax,p%isol
* =====================================================================
c      pint = 0d0
      p%dw =0d0
      p%dtmin = 0d0
cnh
      p%dtmax = 0d0

* =====================================================================
*      common/water/g%won,g%woff,g%wes,g%wesp,g%wex,g%wbp,g%winf,g%h0,g%wp,g%wp0
* =====================================================================
      g%wp = 0d0
      g%wp0 = 0d0

* =====================================================================
*      common/space/p%n, p%x, p%dx
* =====================================================================
      p%n= 0
      p%x(:)=0d0
      p%dx(:)=0d0

* =====================================================================
*      common/soilvr/g%p,g%psi,g%th,g%thold,g%hk,g%q,
*     1              g%h,g%hold,g%ron,g%roff,g%res,g%resp,g%rex,g%qs,g%qex
* =====================================================================
      g%p(:)=0d0
      g%psi(:)=0d0
      g%th(:)=0d0
      g%thold(:)=0d0
      g%hk(:)=0d0
      g%q(:)=0d0
      g%h = 0d0
      g%hold = 0d0
      g%ron = 0d0
      g%roff = 0d0
      g%res = 0d0
      g%resp = 0d0
      g%rex = 0d0
      g%rssf = 0d0
      g%qs(:) = 0d0
      g%qex(:) = 0d0
      g%qexpot(:) = 0d0
      g%qssif(:) = 0d0
      g%qssof(:) = 0d0

* =====================================================================
cnh*      common/bypass/p%ibp,p%gbp,p%sbp,g%hbp,g%hbp0,g%hbpold,g%qbp,g%qbpd,slbp0,g%qslbp
*      common/bypass/p%ibp,p%gbp,p%sbp,g%hbp,g%hbp0,g%hbpold,g%qbp,g%qbpd,g%qslbp
* =====================================================================
      g%qbp = 0d0
      g%qbpd = 0d0
cnh      slbp0 = 0d0
      do 19 counter=1,nsol
         g%qslbp(counter) = 0d0
   19 continue

* =====================================================================
*      common/soilpr/p%ivap,index,wtint,g%hys,g%hysref,
*     1              g%hysdry,g%hyscon,p%sl,p%wc,
*     2              p%wcd,p%hkl,p%hkld
* =====================================================================

      do 211 counter = 0,M
         p%air_dry(counter) = 0d0
         p%LL15(counter) = 0d0
         p%DUL(counter) = 0d0
         p%SAT(counter) = 0d0
         p%Ks(counter) = 0d0
         p%P(counter) = 0d0
         p%k(counter) = 0d0
         p%c(counter) = 0d0
         g%swf(counter) = 0.0
         g%SubSurfaceInFlow(counter) = 0.0
  211 continue
      p%Kdul = 0d0
      p%Psidul = 0d0
      p%ivap = .false.

* =====================================================================
*      common/solute/g%slon,g%sloff,g%slex,g%slbp,g%slinf,g%slh0,g%slsadd,g%slp,g%slp0,
*     1              g%sldrn,g%sldec,g%slprd
* =====================================================================
      do 21 counter=1,nsol

         do 78 node=0,M
            g%cslold(counter,node) = 0d0
   78    continue
         p%cslgw(counter) = 0d0
   21 continue


* =====================================================================
*      common/solvar/g%dc,g%csl,g%cslt,g%qsl,g%qsls,g%slsur,
*     1              g%cslsur,g%rslon,g%rsloff,g%rslex,g%rsldec,g%rslprd,g%qslprd
* =====================================================================
      do 24 counter = 1,nsol
         do 22 node = 1,M
            g%dc(counter,node) =0d0
   22    continue

         do 23 node = 0,M
            g%csl(counter,node)=0d0
            g%cslstart(counter,node)=0d0
            g%cslt(counter,node)=0d0
            g%qsl(counter,node)=0d0
            g%qsls(counter,node)=0d0
   23    continue
         g%slsur(counter) = 0d0
         g%cslsur(counter) = 0d0
         g%rslon(counter) = 0d0
         g%rsloff(counter) = 0d0
         g%rslex(counter) = 0d0
   24 continue

* =====================================================================
*      common/solpar/indxsl,slxc,slpmax,slpc1,slpc2,scycle,itime,
*     1              idepth,asl1,bsl1,asl2,bsl2,p%slupf,p%slos,g%slsci,g%slscr,
*     2              p%dcon,p%dthc,p%dthp,p%disp,p%dis,p%ex,p%fip,
*     3              p%alpha,p%betaex
* =====================================================================
      do 32 counter = 1, nsol
         do 30 counter2 = 0,M
            p%ex(counter,counter2)=0d0
            p%fip(counter,counter2)=0d0
   30    continue

         do 31 counter2 = 0,M
c            indxsl(counter,counter2)=0
   31    continue

         p%slupf(counter) = 0d0
         c%slos(counter) = 0d0
         c%d0(counter) = 0d0
         p%slsci(counter) = 0d0
         p%slscr(counter) = 0d0
         p%dcon(counter) = 0d0
   32 continue
         p%dthc = 0d0
         p%dthp = 0d0
         p%a    = 0d0
         p%dis=0d0         
         p%disp = 0d0
* =====================================================================
*      common/itern/p%ersoil,p%ernode,p%errex,p%dppl,p%dpnl,g%work,p%slcerr,g%slwork
* =====================================================================
      c%ersoil = 0d0
      c%ernode = 0d0
      c%errex = 0d0
      c%dppl = 0d0
      c%dpnl = 0d0
      g%work = 0d0
      c%slcerr = 0d0
      g%slwork = 0d0

* =====================================================================
*      common/condns/g%gf,p%isbc,p%itbc,p%ibbc,p%swt,g%swta,p%slswt
* =====================================================================
      g%gf = 1d0  ! gravity factor set to 1 - only allow flat soil surface
      p%isbc = 0
      p%itbc = 0
      p%ibbc = 0
      p%swt = 0d0
      g%swta(:)=0d0
      p%slswt = 0d0


* =====================================================================
*      common/surcon/p%g0,p%g1,p%grc,p%hm0,p%hm1,p%hrc,p%roff0,p%roff1,tzero,eqr0
* =====================================================================
      p%g0 = 0d0
      p%g1 = 0d0
      p%grc = 0d0
      p%hm0 = 0d0
      p%hm1 = 0d0
      p%hrc = 0d0
      p%roff0 = 0d0
      p%roff1 = 0d0
c      tzero = 0d0
c      eqr0 = 0d0
      g%hmin = 0d0
      g%gsurf = 0d0

* =====================================================================
*      common/vegvar/g%rld,g%rc,g%rtp,g%rt,g%ctp,g%ct,g%qr,g%slup
* =====================================================================

      do 41 vegnum = 1, MV
         do 39 solnum=1,nsol
            g%slup (vegnum,solnum) = 0d0
   39    continue
         do 40 node = 0,M
            g%rld(node,vegnum) = 0d0
            g%rc (node,vegnum) = 0d0
            g%qr (node,vegnum) = 0d0
            g%qrpot (node,vegnum) = 0d0
   40    continue
         g%rtp (vegnum) = 0d0
         g%rt  (vegnum) = 0d0
         g%ctp (vegnum) = 0d0
         g%ct  (vegnum) = 0d0
   41 continue

* =====================================================================
*      common/vegpar/g%nveg,g%psim,g%psimin,xc,rldmax,fevmax,
*     1              vcycle,igrow,iroot,arld1,brld1,
*     1              arld2,brld2
* =====================================================================
       g%nveg = 0


      do 102 vegnum=1,MV
         g%pep(vegnum) = 0d0
         g%canopy_height(vegnum) = 0d0
         g%cover_tot(vegnum) = 0d0
         do 101 solnum=1,nsol
            g%solute_demand(vegnum,solnum) = 0d0
            g%demand_is_met(vegnum,solnum) = .false.
  101    continue
  102 continue

      g%crops_found = .false.
      g%start_year = 0
      g%start_day = 0
      g%num_crops = 0
      g%nveg = 0
      g%potet = 0.0
      g%rain = 0.0
      g%mint = 0d0
      g%maxt = 0d0
      g%radn = 0d0

      g%SWIMRainNumPairs = 0 
      g%SWIMEvapNumPairs = 0
      g%work = 0d0
      g%psim = 0d0
      g%residue_cover = 0d0
      g%cover_green_sum = 0d0
      g%CN_runoff = 0d0
      g%t = 0d0
      g%cover_surface_runoff = 0.0

      do 50 vegnum = 1,MV
         g%psimin(vegnum) = 0d0
         g%root_radius(:,vegnum) = 0d0
         g%root_conductance(:,vegnum) = 0d0
         g%crop_names(vegnum) = ''
         g%crop_owners(vegnum) = ''
         g%crop_owner_id(vegnum) = 0
         g%crop_in(vegnum) = .false.
         g%supply_event_id(vegnum) = 0
   50 continue

      return
      end subroutine

* ====================================================================
       subroutine apswim_zero_module_links ()
* ====================================================================

      implicit none

*+  Purpose
*     Reset all information regarding links to other modules

*+  Local Variables
       integer solnum

*- Implementation Section ----------------------------------

      p%num_solutes = 0
      do 100 solnum=1,nsol
         p%solute_names(solnum) = ' '
         g%solute_owners(solnum) = 0
  100 continue

      return
      end subroutine

* ====================================================================
       subroutine apswim_Prepare ()
* ====================================================================

      implicit none

*+  Purpose
*     Perform calculations before the current timestep.

*+  Local Variables

*- Implementation Section ----------------------------------

      call apswim_get_other_variables ()

      call apswim_get_rain_variables ()

      call apswim_recalc_eqrain()

      if (p%evap_source .eq. 'calc') then
         ! I need a cumulative eo curve from Priestly taylor
         ! method for these pot. evap methods.
         call apswim_calc_evap_variables ()

      else
         call apswim_get_obs_evap_variables ()
      endif

      return
      end subroutine



* ====================================================================
       subroutine apswim_init_calc ()
* ====================================================================

      implicit none

*+  Purpose
*   Perform initial calculations from input parameters and prepare for
*   simulation

*+  Local Variables
      double precision fraction
      double precision hklg
      double precision hklgd
      integer layer
      integer i                        ! simple counter variable
      integer j
      integer k
      integer l
      integer          node
      integer          solnum
      integer          num_layers
      double precision suction
      double precision thd
      double precision Rll, slope
c      double precision tth
      double precision thetaj, thetak, dthetaj, dthetak
      double precision hklgj, hklgk, dhklgj, dhklgk
       integer          time_mins
      double precision b
      double precision Sdul

*- Implementation Section ----------------------------------
      
      ! change units of params to normal SWIM units
      ! ie. cm and hours etc.
      call apswim_init_change_units()

* ------------------- CALCULATE CURRENT TIME -------------------------
      time_mins = apswim_time_to_mins (g%apsim_time)
      g%t = apswim_time (g%year,g%day,time_mins)

* ----------------- SET UP NODE SPECIFICATIONS -----------------------
      
      ! safer to use number returned from read routine
      num_layers = count_of_double_vals (p%dlayer,M+1)
      p%n = num_layers -1
 
      p%dx(:) = p%dlayer(:)/10d0
           
      p%x(0) = 0d0
      p%x(1) = 2d0*p%dx(0) + p%x(0)
      do i=2,p%n-1
c         p%x(i) = (2d0*(sum(p%dlayer(0:i-1))-p%x(i-1))+p%x(i-1))
         p%x(i) = 2d0*p%dx(i-1) + p%x(i-2)
      enddo
      p%x(p%n) = sum(p%dx(0:p%n))
      
c      p%dx(0) = 0.5*(p%x(1) - p%x(0))
c      do 10 i=1,p%n-1
c         p%dx(i) = 0.5*(p%x(i+1)-p%x(i-1))
c   10 continue
c      p%dx(p%n) = 0.5*(p%x(p%n)-p%x(p%n-1))


          
* ------- IF USING SIMPLE SOIL SPECIFICATION CALCULATE PROPERTIES -----



      call SetupThetaCurve()   
      call SetupKCurve ()                
         
* ---------- NOW SET THE ACTUAL WATER BALANCE STATE VARIABLES ---------
    
      if (g%th(1).ne.0) then
         ! water content was supplied in input file
         ! so calculate matric potential
         call apswim_reset_water_balance (1,g%th)

      else
         ! matric potential was supplied in input file
         ! so calculate water content
         call apswim_reset_water_balance (2,g%psi)
      endif


      ! Calculate Water Table If Required
      if (p%ibbc.eq.1) then
         p%bbc_value = p%x(p%n) - p%bbc_value/10d0
      else if (p%ibbc.eq.4) then
         !p%bbc_value = p%x(p%n) - p%bbc_value/10d0
         ! Now reset theta to saturated below the water table
c         do 50 node = 0,p%n
c            if (p%x(node).gt.(p%bbc_value/10d0 - 100d0))then
c               g%psi(node) = p%x(node)-p%bbc_value/10d0
c               g%th(node) = apswim_Simpletheta(node,g%psi(node))
c               g%p(node)=apswim_pf(g%psi(node))
c            endif
c   50    continue
   
         g%psi(p%n) = p%x(p%n)-p%bbc_value/10d0
         g%th(p%n) = apswim_Simpletheta(p%n,g%psi(p%n))
         g%p(p%n)=apswim_pf(g%psi(p%n))
            
      endif

      return
      end subroutine

* ====================================================================
      subroutine SetupThetaCurve()
* ====================================================================
      integer layer
      double precision alpha,beta,phi,tau

*- Implementation Section ----------------------------------

         do 26 layer =0,p%n
            p%psid(layer) = p%Psidul !- (p%x(p%n) - p%x(layer))
            
            g%DELk(layer,1) = (p%dul(layer) - p%sat(layer))
     :                /(Log10(-p%psid(layer)))
            g%DELk(layer,2) = (p%ll15(layer) - p%dul(layer)) 
     :        / (Log10(-psi_ll15) - Log10(-p%psid(layer)))
            g%DELk(layer,3) = -p%ll15(layer) 
     :        / (Log10(-psi0) - Log10(-psi_ll15))
            g%DELk(layer,4) = -p%ll15(layer) 
     :        / (Log10(-psi0) - Log10(-psi_ll15))     
     
      g%Mk(layer,1) = 0d0
      g%Mk(layer,2) = (g%DELk(layer,1) + g%DELk(layer,2)) / 2d0
      g%Mk(layer,3) = (g%DELk(layer,2) + g%DELk(layer,3)) / 2d0
      g%Mk(layer,4) = g%DELk(layer,4)

      ! First bit might not be monotonic so check and adjust
      alpha = g%Mk(layer,1) / g%DELk(layer,1)
      beta = g%Mk(layer,2) / g%DELk(layer,1)
      phi = alpha-((2*alpha+beta-3)**2 /(3*(alpha + beta - 2)))
      If (phi .le.0) Then
         tau = 3 / ((alpha**2 + beta**2)**0.5)
         g%Mk(layer,1) = tau * alpha * g%DELk(layer,1)
         g%Mk(layer,2) = tau * beta * g%DELk(layer,1)
      EndIf

         g%m0(layer,1) = 0
         g%m1(layer,1) = 0
         g%Y0(layer,1) = p%sat(layer)
         g%Y1(layer,1) = p%sat(layer)

         g%m0(layer,2) = g%Mk(layer,1) * (Log10(-p%psid(layer)) - 0d0)
         g%M1(layer,2) = g%Mk(layer,2) * (Log10(-p%psid(layer)) - 0d0) 
         g%Y0(layer,2) = p%sat(layer)
         g%Y1(layer,2) = p%dul(layer)

         g%m0(layer,3)=g%Mk(layer,2)
     :                *(Log10(-psi_ll15)-Log10(-p%psid(layer)))
         g%M1(layer,3)=g%Mk(layer,3)
     :                *(Log10(-psi_ll15)-Log10(-p%psid(layer)))
         g%Y0(layer,3) = p%dul(layer)
         g%Y1(layer,3) = p%ll15(layer)

         g%m0(layer,4) = g%Mk(layer,3)
     :                 * (Log10(-psi0) - Log10(-psi_ll15))
         g%M1(layer,4) = g%Mk(layer,4) 
     ;                 * (Log10(-psi0) - Log10(-psi_ll15))
         g%Y0(layer,4) = p%ll15(layer)
         g%Y1(layer,4) = 0d0

         g%m0(layer,5) = 0
         g%M1(layer,5) = 0
         g%Y0(layer,5) = 0
         g%Y1(layer,5) = 0
   
   26    continue      
      return
      end subroutine
      
* ====================================================================
      subroutine SetupKCurve()
* ====================================================================

      integer layer
      double precision b
      double precision Sdul

*- Implementation Section ----------------------------------

      do 100 layer=0,p%n
         b = -log(p%Psidul/psi_ll15)/log(p%dul(layer)/p%ll15(layer))
         g%MicroP(layer) = b*2d0+3d0
         g%Kdula(layer) = min(0.99*p%Kdul,p%Ks(layer))
         g%MicroKs(layer) = g%Kdula(layer)/(p%dul(layer)/p%sat(layer))
     :                                         **g%MicroP(layer)

         Sdul = p%dul(layer)/p%sat(layer)
         g%MacroP(layer)=Log10(g%Kdula(layer)/99d0
     :                   /(p%Ks(layer)-g%MicroKs(layer)))/Log10(Sdul)
 100  continue
      
      return
      end subroutine
      
* ====================================================================
       subroutine apswim_interp (node,tpsi,tth,thd,hklg,hklgd)
* ====================================================================


      implicit none

*+  Sub-Program Arguments
       integer          node
       double precision tpsi
       double precision tth
       double precision thd
       double precision hklg
       double precision hklgd

*+  Purpose
*   interpolate water characteristics for given potential for a given
*   node.

*+  Constant Values
      character myname*(*)               ! name of current procedure
      parameter (myname = 'apswim_interp')
      double precision dpsi
      parameter (dpsi = 0.0001d0)

*+  Local Variables
      double precision temp

*- Implementation Section ----------------------------------
         tth   = apswim_Simpletheta(node,tpsi)
         temp  = apswim_Simpletheta(node,tpsi+dpsi)
         thd   = (temp-tth)/log10((tpsi+dpsi)/tpsi)
         hklg  = log10(apswim_SimpleK(node,tpsi))
         temp  = log10(apswim_SimpleK(node,tpsi+dpsi))
         hklgd = (temp-hklg)/log10((tpsi+dpsi)/tpsi)
      return
      end subroutine

* ====================================================================
       double precision function Apswim_SimpleS (layer, psi)
* ====================================================================
      implicit none

*+  Sub-Program Arguments
      integer layer
      double precision    psi
      double precision    S1,S2,wt
*+  Purpose
*      Calculate S for a given node for a specified suction.

       double precision temp
*- Implementation Section ----------------------------------
      
      Apswim_SimpleS = Apswim_SimpleTheta(layer,psi)/p%sat(layer)
      

      return
      end function

* ====================================================================
       double precision function Apswim_Simpletheta (layer, psi)
* ====================================================================

      implicit none

*+  Sub-Program Arguments
      integer layer
      double precision    psi

*+  Purpose
*      Calculate Theta for a given node for a specified suction.

*+  Local Variables
      double precision S
      double precision logpsi
      double precision Y,T
      integer i
      
*- Implementation Section ----------------------------------


      if (psi.ge.-1d0) then
         i = 1
         T = 0    
      elseIf (psi .gt. p%psid(layer)) Then
         i = 2
         T = (Log10(-psi) - 0d0) / (Log10(-p%psid(layer)) - 0d0)
      ElseIf (psi .gt. psi_ll15) Then
         i = 3
         T = (Log10(-psi) - Log10(-p%psid(layer))) 
     :         / (Log10(-psi_ll15) - Log10(-p%psid(layer)))
         
      Elseif (psi .gt. psi0) then
         i = 4
         T = (Log10(-psi) - Log10(-psi_ll15)) 
     :        / (Log10(-psi0) - Log10(-psi_ll15))
      else
         i = 5
         T = 0
      End If

      Y = (2 * T**3 - 3 * T**2 + 1) * g%Y0(layer,i) 
     :  + (T**3 - 2 * T**2 + T) * g%m0(layer,i) 
     :  + (-2 * T**3 + 3 * T**2) * g%Y1(layer,i) 
     :  + (T**3 - T**2) * g%M1(layer,i)

      Apswim_Simpletheta = Y
      return
      end function

* ====================================================================
       double precision function apswim_SimpleK (layer, psi)
* ====================================================================
      implicit none


*+  Sub-Program Arguments
      integer layer
      double precision    psi

*+  Purpose
*      Calculate Conductivity for a given node for a specified suction.


*+  Constant Values

      character*(*) myname               ! name of current procedure
      parameter (myname = 'apswim_SimpleK')

      double precision Kll
      parameter (Kll = 6d-6*10d0)


*+  Local Variables
      double precision S
      double precision MicroK
      double precision MacroK

*- Implementation Section ----------------------------------

      
       S = Apswim_SimpleS(layer,psi)
       if (S.le.0d0) then
          apswim_SimpleK = 1d-100
       else
              


         MicroK = g%MicroKs(layer)*S**g%MicroP(layer)
         
         if(g%MicroKs(layer).ge.p%Ks(layer)) then
            apswim_SimpleK = MicroK
         else

            MacroK = (p%Ks(layer)-g%MicroKs(layer))*S**g%MacroP(layer)
            apswim_SimpleK = (MicroK+MacroK)
         endif
      endif
         
      apswim_SimpleK = apswim_SimpleK/24d0/10d0
      return
      end function

* ====================================================================
       double precision function apswim_suction (node, theta)
* ====================================================================


      implicit none

*+  Sub-Program Arguments
      integer node
      double precision theta, logpsi

*+  Purpose
*   Calculate the suction for a given water content for a given node.


*+  Local Variables
      integer max_iterations
      parameter (max_iterations = 1000)
      double precision tolerance
      parameter (tolerance = 1d-9)
      double precision dpsi
      parameter (dpsi = 0.01d0)


      double precision psi
      double precision est,m
      logical          solved
      integer          iteration
      
*- Implementation Section ----------------------------------

c      if (theta.ge.p%dul(node)) then
c         psi =-10**((1d0-theta/p%sat(node))/p%k(node))**(1d0/p%c(node))
c      else
c         logpsi = log10(-psiad)-(log10(-psiad)-log10(-p%psid(node)))
c     :        * (theta-p%air_dry(node))**(1d0/p%P(node))
c     :         /(p%dul(node)-p%air_dry(node))
c        psi = -10d0**logpsi
c      endif

      ! Use numerical solution in preparation for when various methods
      ! are supported for describing the SMC
 
      if (theta.eq.p%sat(node)) then
          psi = 0d0
      else
      
         psi = -100d0  ! Initial estimate
         solved = .false.
         do 100 iteration = 1,max_iterations
            est = apswim_Simpletheta(node,psi)
            m = (apswim_Simpletheta(node,psi+dpsi)-est)/dpsi

            if (abs(est-theta) .lt. tolerance) then
               solved = .true.
               goto 200
            else
               psi = psi - (est-theta)/m
            endif
  100    continue
  200    continue
      endif

      apswim_suction = psi
      return
      end function



* ====================================================================
       logical function apswim_swim (timestep_start, timestep)
* ====================================================================


      implicit none

*+  Sub-Program Arguments
       double precision timestep
       double precision timestep_start

*+  Notes
*     SWIM solves Richards' equation for one dimensional vertical soil water
*     infiltration and movement.  A surface seal, variable height of surface
*     ponding, and variable runoff rates are optional.  Deep drainage occurs
*     under a given matric potential gradient or given potl or zero flux or
*     seepage.  The method uses a fixed space grid and a sinh transform of
*     the matric potential, as reported in :
*     Ross, P.J., 1990.  Efficient numerical methods for infiltration using
*     Richards' equation.  Water Resources Res. 26, 279-290.

*+  Changes
*     26/11/1999 dph changed action_send(unknown_module, action, data)
*                    to action_send_to_all_comps(action)
*     RCichota - 09-Feb-2010 - make SWIM reset solute values if fail to solve and 
*                    tell user the value of dt


*+  Local Variables
      double precision dr
      double precision deqr
      double precision dtiny
      double precision dw1
      integer          crop
      integer          i
      integer          itlim
      integer          node
      integer          solnum
*
cnh added next line
c      double precision psiold(0:M)
      double precision qmax
      double precision wpold
      double precision pold(0:M)
      double precision timestep_remaining
      logical          fail
      double precision crt
      double precision t1
      double precision t2
      double precision old_time
      double precision old_hmin
      double precision old_gsurf
      double precision LogTime
      character string*100

*- Implementation Section ----------------------------------

      TimeStep_remaining = timestep
      g%t = Timestep_start
      fail = .false.

*     define iteration limit for soln of balance eqns
      if (g%run_has_started) then
         !itlim = 20
         itlim = c%max_iterations
      else
         ! this is our first timestep - allow for initial stabilisation
         !itlim = 50
         itlim = c%max_iterations + 20
      endif

*     solve until end of time step

10    continue
cnh
      call event_send(unknown_module,'swim_timestep_preparation')

*        calculate next step size_of g%dt

         ! Start with first guess as largest size_of possible
         g%dt = p%dtmax
         if(Doubles_are_equal(p%dtmin,p%dtmax))then
            g%dt=p%dtmin
         else
            if(.not.g%run_has_started)then
               if(Doubles_are_equal(p%dtmin,0d0)) then
                  g%dt=min(0.01*(timestep_remaining),0.25d0)
               else
                  g%dt=p%dtmin
               endif
               g%ron=0.
               qmax=0.

            else
               qmax=0.
               qmax=max(qmax,g%roff)
               qmax=max(qmax,g%res)
               do 15 i=0,p%n
                  qmax=max(qmax,g%qex(i))
                  !qmax=max(qmax,g%qexpot(i)) ! this to make steps small when pot is large therefore to
                                             ! provide accurate pot supply back to crops
                  qmax=max(qmax,abs(g%qs(i)))
                  qmax=max(qmax,abs(g%qssif(i)))
                  qmax=max(qmax,abs(g%qssof(i)))
15             continue
               do 20 i=0,p%n+1
                  qmax=max(qmax,abs(g%q(i)))
20             continue
               if (qmax.gt.0) then
                  g%dt=ddivide(p%dw,qmax,0.d0)
               else
                  ! No movement
               endif

            end if

cnh            g%dt=min(g%dt,p%dtmax)
cnh            g%dt=max(g%dt,p%dtmin)
            g%dt = dubound(g%dt,timestep_remaining)

            crt = apswim_crain(g%t)
            dr = apswim_crain(g%t+g%dt) - crt

            if (g%ron.eq.0)then
               dw1 = 0.1*p%dw
            else
               dw1 = p%dw
            endif

            if (dr.gt.1.1*dw1) then
               t1 = g%t
               do 30 i=1,10
                  g%dt = 0.5*g%dt
                  t2 = t1+g%dt
                  dr = apswim_crain(t2)-crt
                  if (dr.lt.0.9*dw1) then
                     t1=t2
                  else
                     if (dr.le.1.1*dw1) goto 31
                  endif
 30            continue
 31            g%dt=t2-g%t
            endif

            g%dt=min(g%dt,p%dtmax)
            g%dt=max(g%dt,p%dtmin)

cnh Commented out until fully tested need for constraining timestep to within Eo boundaries.
!            if(sum(g%pep(1:g%num_crops)).gt.0.0) then
!               ! there are crops requiring water. Therefore do not step past the start and end
!               ! of daily ET period.
!               ! need to limit timestep to not step past a point on the evap or rainfall log
!c               LogTime = NextLogTime(g%SWIMRainTime,g%SWIMRainNumPairs)
!c               g%dt=min(g%dt,LogTime-g%t)
!                LogTime = NextLogTime(g%SWIMEvapTime,g%SWIMEvapNumPairs)
!                !g%dt=min(g%dt,LogTime-g%t)
!
!               if (g%res.eq.0d0) then
!                  ! last step was night time - better check if we are starting a new day and
!                  ! allow for change in evaporation rates
!                  qmax=max(qmax,
!     :             (apswim_cevap(g%t+g%dt)-apswim_cevap(g%t+g%dt))/g%dt)
!               endif
!               if (qmax.gt.0) then
!                  !g%dt=min(g%dt,ddivide(p%dw,qmax,0.d0))
!               else
!                  ! No Evap so no change to dt required
!               endif
!            endif
!cnh            g%dt = dubound(g%dt,timestep_remaining)


         end if


         dtiny=max(0.01d0*g%dt,p%dtmin)

*        initialise and take new step
*        ----------------------------

         wpold=g%wp
         g%hold=g%h
         do 34 i=0,p%n
*           save transformed potls and water contents
            pold(i)=g%p(i)
            g%thold(i)=g%th(i)
            old_hmin = g%hmin
            old_gsurf = g%gsurf
cnh
c            psiold(i) = g%psi(i)
            do 78 solnum=1,p%num_solutes
               g%cslold(solnum,i) = g%csl(solnum,i)
   78       continue
34       continue

         old_time = g%t


*        new step
40       continue

            g%t = g%t + g%dt
            If (Timestep_remaining - g%dt .lt. 0.1*g%dt) then
               g%t = g%t - g%dt + timestep_remaining
               g%dt = Timestep_remaining
            Else
            Endif


            dr=apswim_crain(g%t) - apswim_crain(g%t-g%dt)
            g%ron=dr/g%dt ! it could just be rain_intensity

cnh
            do 41 i=1,p%num_solutes
               g%rslon(i) = (apswim_csol(i,g%t)
     :                       - apswim_csol(i,g%t-g%dt))/g%dt
   41       continue

            call apswim_pstat(0,g%resp)

            deqr = apswim_eqrain(g%t) - apswim_eqrain(g%t-g%dt)
            if (p%isbc.eq.2) then
               call apswim_hmin (deqr,g%hmin)
            else
            endif
            if (p%itbc.eq.2) then
               call apswim_gsurf (deqr,g%gsurf)
            else
            endif
cnh
            call apswim_check_demand()

cnh
         call event_send(unknown_module,'pre_swim_timestep')
***
*           integrate for step g%dt
            call apswim_solve(itlim,fail)

            if(fail)then
!              SWIM failed to find a solution, should reset values to its previous state 
!               and attempt to solve again with a smaller dt
			
                call apswim_diagnostics(pold)
             ! Reset values
               g%t = old_time
               g%hmin = old_hmin
               g%gsurf = old_gsurf
                g%wp=wpold
               g%dt=0.5*g%dt
               g%h=g%hold
               do 42 i=0,p%n
                  g%p(i)=pold(i)
                  g%th(i) = g%thold(i)
                  do 44 solnum=1,p%num_solutes
                     g%csl(solnum,i) = g%cslold(solnum,i)
44                continue				  
42             continue
cRC   lines for g%th and g%csl added by RCichota, 09/02/2010

               g%dt=0.5*g%dt

!              Tell user that SWIM is changing dt
               write(string,'(a,f15.3,a,f15.3)')
     :               'Changing dt value from: ', g%dt*2
     :               ,' to: ', g%dt
               call write_string('ApsimSwim|apswim_swim - '//string)
               if(g%dt.ge.dtiny)go to 40
            else

*
*              update variables
               g%TD_runoff = g%TD_runoff + g%roff*g%dt*10d0
               g%TD_evap   = g%TD_evap   + g%res*g%dt*10d0
               g%TD_drain  = g%TD_drain  + g%q(p%n+1)*g%dt*10d0
               g%TD_rain   = g%TD_rain   + g%ron*g%dt*10d0
               g%TD_pevap  = g%TD_pevap  + g%resp*g%dt*10d0
               g%TD_subsurface_drain = g%TD_subsurface_drain
     :                               + sum(g%qssof(0:p%n))*g%dt*10d0
               do 53 node = 0,p%n+1
                  g%TD_wflow(node) = g%TD_wflow(node)
     :                           + g%q(node)*g%dt*10d0
   53          continue

               do 51 solnum = 1, p%num_solutes
                  ! kg    cm ug          g   kg
                  ! -- = (--p%x--) p%x hr p%x -- p%x --
                  ! ha    hr  g         ha   ug

                  g%TD_soldrain(solnum) = g%TD_soldrain(solnum)
     :                     + (
     :                       g%qsl(solnum,p%n+1)*g%dt
     :                     * (1d4)**2   ! cm^2/ha = g/ha
     :                     * 1d-9       ! kg/ug
     :                       )


                  do 52 node=0,p%n+1
                     g%TD_sflow(solnum,node) =
     :                    g%TD_sflow(solnum,node)
     :                  + g%qsl(solnum,node)*g%dt*(1d4)**2*1d-9
                     g%TD_slssof(solnum) = g%TD_slssof(solnum)
     :                  + g%csl(solnum,node)*g%qssof(node)
     :                  *g%dt*(1d4)**2*1d-9
   52             continue
   51          continue

cnh
               call apswim_pstat(1,g%resp)
                  !if(p%slupf(solnum).ne.0.)then
                     call apswim_pstat(2,g%resp)
                  !else
                  !endif


cnh
               call event_send(unknown_module,'post_swim_timestep')

            end if

      ! We have now finished our first timestep
         g%run_has_started = .true.
         timestep_remaining = timestep_remaining - g%dt
      if(Timestep_remaining.gt.0.0 .and..not.fail)go to 10

      apswim_swim = fail

      return
      end function



* ====================================================================
       integer function apswim_time_to_mins (timestring)
* ====================================================================

      implicit none

*+  Sub-Program Arguments
       character timestring*(*)

*+  Local Variables
       integer colon
       integer hour
       integer mins
       character hourstring*4
       character minstring*4
       integer numvals

*- Implementation Section ----------------------------------

      colon = index(timestring,':')

      if (colon .eq. 0) then
         call fatal_error(err_user,'bad time format')
         hour = 0
         mins = 0
      else
         call split_line (timestring,hourstring,minstring,':')
         call string_to_integer_var(hourstring,hour,numvals)
         call string_to_integer_var(minstring,mins,numvals)
      endif

      apswim_time_to_mins = hour*60 + mins

      return
      end function



* ====================================================================
       subroutine apswim_Process ()
* ====================================================================

      implicit none

*+  Purpose
*      Perform actions for current g%day.

*+  Notes
*       The method of limiting timestep to rainfall data will mean that
*       insignificantly small rainfall events could tie up processor time
*       for limited gain in precision.  We may need to adress this later
*       by enabling two small rainfall periods to be summed to create
*       one timestep instead of two.


*+  Local Variables
      logical fail
      integer time_of_day
      double precision timestep_start
      double precision timestep

      character string*100
      integer          solnum
      integer          node
*- Implementation Section ----------------------------------

      call apswim_reset_daily_totals()
      call apswim_get_other_variables ()
      call apswim_get_solute_variables ()

      !if (.not. g%crops_found) then
      !   call apswim_find_crops()
      !   call apswim_assign_crop_params ()
      !   call apswim_register_crop_outputs()
      !   g%crops_found = .true.
      !endif
      call apswim_get_crop_variables ()
      call apswim_get_residue_variables ()
      call apswim_remove_interception ()
      call apswim_CN_Runoff()

      time_of_day = apswim_time_to_mins (g%apsim_time)
      timestep_start = apswim_time (g%year,g%day,time_of_day)
      timestep       = g%apsim_timestep/60.d0

      fail = apswim_swim (timestep_start,timestep)

      if (fail) then
         call apswim_report_status()
         call fatal_error (Err_Internal, 'Swim failed to find solution')
      else
!````````````````````````````````````````````````````````````````````````````````
              !Test for negative values of g%csl coming from the thomas algorithm.
              ! disregard if very small, else cause fatal error
cRC            Changes by RCichota, 30/Jan/2010, ammended in 10/Jul/2010

               do 55 solnum = 1,p%num_solutes
                  do 56 node = 0, p%n
                     if (abs(g%csl(solnum,node)).lt.-c%slcerr) then
     :                  ! value is negative, throw a fatal error (using same error limit as for thomas algorithm, may need to look at this better)
                        write(string,*)
     :                        '  Solution '
     :                        ,p%solute_names(solnum)
     :                        (:lastnb(p%solute_names(solnum)))
     :                        ,'(',node,') = ',g%csl(solnum,node)
                        call fatal_error(err_internal,
     :                        '-ve value when calculating'
     :                        //' solute movement'
     :                        //new_line//string)

                        g%csl(solnum,node) = 0d0

                     elseif (g%csl(solnum,node) .lt. 1d-100) then
                        ! Value is REALY small, set to zero to avoid underfolw with reals

                        g%csl(solnum,node) = 0d0

                     else
                        ! value is OK. proceed with calculations
                     endif
   56             continue
   55          continue

!````````````````````````````````````````````````````````````````````````````````

         call apswim_set_other_variables ()
         call apswim_set_solute_variables()
      endif

      call PublishUptakes()
      
      return
      end subroutine



* ====================================================================
       subroutine apswim_sum_report ()
* ====================================================================

      implicit none

*+  Purpose
*   Report all initial conditions and input parameters to the
*   summary file.

*+  Constant Values
      integer num_psio
      parameter (num_psio = 8)

*+  Local Variables
       double precision hklgd
       integer   i
       integer   j
       integer   layer                   ! soil layer number
       integer   nlayers                 ! number of soil layers
       character string*200              ! output string
       double precision thd
*
*
      double precision tho(0:M,num_psio)
      double precision hklo(0:M,num_psio)
      double precision hko (0:M,num_psio)

*+  Initial Data Values
      double precision psio(num_psio)
c      data psio/-1.d-2,-10.d0,-100.d0,-1000.d0,-15000.d0,-1.d5,-1.d6
c     :           ,-1d7/
      data psio/-1.d-2,-10.d0,-25.d0,-100.d0,-1000.d0,-15000.d0,-1.d6
     :           ,-1d7/   

*- Implementation Section ----------------------------------
      
      string = New_Line//New_Line
     :      //'                      APSIM Soil Profile'//New_Line
     :      //'                      ------------------'//New_Line
      call write_string (string)

      string =     
     :'---------------------------------------------------------------'
     : //New_Line//
     : ' x    dlayer   BD   SW     LL15   DUL   SAT      Ks      Psi'
      call write_string (string)
      string =    
     :'---------------------------------------------------------------'
      call write_string (string)


      do 100 layer = 0,p%n
         write(string,'(f6.1,x,f6.1,2x,f4.2,4(2x,f5.3),x,f6.2,x,f8.1)')
     :       p%x(layer)*10.,
     :       p%dlayer(layer), p%rhob(layer), g%th(layer),
     :       p%LL15(layer), p%DUL(layer), p%SAT(layer), p%Ks(layer),
     :       g%psi(layer)
         call write_string (string)
  100 continue
      string =    
     :'---------------------------------------------------------------'
      call write_string (string)

      ! calculate Theta and g%hk for each psio
      
      do 210 i=1,num_psio
         do 205 j=0,p%n
            call apswim_interp(j,psio(i),tho(j,i),thd,hklo(j,i),hklgd)
            hko(j,i) = 10d0**hklo(j,i)
  205    continue
  210 continue
      

      string = New_Line//New_Line
     ://'                  Soil Moisture Characteristics'//New_Line
     ://'                  -----------------------------'//New_Line

      call write_string (string)
      string =
     :'------------------------------------------------------------'//
     :'--------'
      call write_string (string)
      string = 
     :'                         Soil Water Potential (cm)'
      call write_string (string)
      string =
     :'    x       0      10      25    100   1000  15000   10^6   10^7'
      call write_string (string)

      string =
     :'------------------------------------------------------------'//
     :'--------'
      call write_string (string)

      do 220 j=0,p%n 
         write(string,'(f6.1,1x,''|'',8(1x,f6.4))')
     :              p%x(j)*10., (tho(j,i),i=1,num_psio)
         call write_string (string)
  220 continue
      string =
     :'------------------------------------------------------------'//
     :'--------'
      call write_string (string)

      string = New_Line//New_Line
     ://'                   Soil Hydraulic Conductivity'//New_Line
     ://'                   ---------------------------'//New_Line

      call write_string (string)
      string =
     :'------------------------------------------------------------'//
     :'-----------'
      call write_string (string)
      string = 
     :'                         Soil Water Potential (cm)'
      call write_string (string)
      string =
     :'    x       0        10       25       100     1000    15000'//
     :'     10^6'
      call write_string (string)

      string =
     :'------------------------------------------------------------'//
     :'-----------'
      call write_string (string)

      do 225 j=0,p%n 
         write(string,'(f6.1,1x,''|'',7(1x,g8.3))')
     :              p%x(j)*10., (hko(j,i)*24d0*10d0,i=1,(num_psio-1))
         call write_string (string)
  225 continue

      string =
     :'------------------------------------------------------------'//
     :'-----------'     
      call write_string (string)
            
 
      call write_string (new_line)

      if (p%ibbc.eq.0) then
         write(string,'(a,f10.3,a)')
     :        '     bottom boundary condition = specified gradient (',
     :         p%bbc_value,')'
         call write_string (string)

      else if(p%ibbc.eq.1) then
         string = '     bottom boundary condition = specified potential'
         call write_string (string)

      else if(p%ibbc.eq.2) then
         call write_string (
     :        '     bottom boundary condition = zero flux')

      else if(p%ibbc.eq.3) then
         call write_string (
     :        '     bottom boundary condition = free drainage')

      else if(p%ibbc.eq.4) then
         call write_string (
     :        '     bottom boundary condition = water table')

      else
         call fatal_error(err_user,
     :                 'bad bottom boundary conditions switch')
      endif

      if (p%ivap) then
         call write_string ('     vapour conductivity       = on')
      else
         call write_string ('     vapour conductivity       = off')
      endif


      string = '     Evaporation Source        = '//p%evap_source
     :               //new_line
      call write_string (string)

      if (p%subsurface_drain.eq.'on') then
      
         call write_string (' Subsurface Drain Model')
         call write_string (' ======================'//new_line)
         
         write(string,'(a,f10.3)')
     :        '     Drain Depth (mm) =',
     :         p%drain_depth
         call write_string (string)      
         write(string,'(a,f10.3)')
     :        '     Drain Spacing (mm) =',
     :         p%drain_spacing
         call write_string (string)               
         write(string,'(a,f10.3)')
     :        '     Drain Radius (mm) =',
     :         p%drain_radius
         call write_string (string)      
         write(string,'(a,f10.3)')
     :        '     Imperm Layer Depth (mm) =',
     :         p%imperm_depth
         call write_string (string)      
         write(string,'(a,f10.3)')
     :        '     Lateral Conductivity (mm/d) =',
     :         p%Klat
         call write_string (string)                                 
      endif

      return
      end subroutine



* ====================================================================
       subroutine apswim_reset_daily_totals()
* ====================================================================

      implicit none

*+  Local Variables
      integer node
      integer solnum
      integer vegnum

*- Implementation Section ----------------------------------

      g%TD_runoff  = 0.0
      g%TD_rain    = 0.0
      g%TD_evap    = 0.0
      g%TD_pevap   = 0.0
      g%TD_drain   = 0.0
      g%TD_subsurface_drain   = 0.0
      g%TD_slssof(:) = 0d0

      g%TD_soldrain(:) = 0d0
      g%TD_wflow(:) = 0d0
      g%TD_sflow(:,:) = 0d0

         do 61 vegnum=1,MV
            do 62 node=0,M
               do 63 solnum=1,nsol
                  g%psuptake(solnum,vegnum,node) = 0d0
   63          continue
               g%pwuptake(vegnum,node) = 0d0
               g%pwuptakepot(vegnum,node) = 0d0
               g%psix(vegnum) = 0d0
   62       continue
   61    continue

      return
      end subroutine



* ====================================================================
       subroutine apswim_check_inputs ()
* ====================================================================

      implicit none

*+  Local Variables

*- Implementation Section ----------------------------------



      return
      end subroutine



* ====================================================================
       subroutine apswim_init_defaults ()
* ====================================================================

      implicit none
      real temp(0:M)
      integer numvals

*- Implementation Section ----------------------------------

      g%gf = 1.d0 !gravity factor will always be one(i.e. vertical profile)

      ! It would be difficult to have all solutes in surface water at
      ! initialisation specified and so we will not allow surface water
      ! at initialisation.
      g%h = 0.0
cnh      g%cslsur = 0.0

      g%start_day = g%day
      g%start_year = g%year

cnh swim2 set soil surface stuff to no solute and no roughness at start
cnh until some cultivation takes place.
cnh      tzero = 100.*365.*24.
cnh      g%cslsur = 0.d0 ! its an array now


      ! initial surface conditions are set to initial maximums.
c      tzero = 0.d0
c      eqr0  = 0.d0

      ! No solutes uptakes are calculated by this model
      p%slupf(:) = 0d0
      
      ! Infinite surface conductance
      p%itbc = 0
      ! No storage of water on soil surface
      p%isbc = 0

      g%subsurface_drain_open = .false.
      
      return
      end subroutine



* ====================================================================
       double precision function apswim_crain (time)
* ====================================================================

      implicit none

*+  Sub-Program Arguments
       double precision time

*+  Local Variables
      double precision crain_mm

*- Implementation Section ----------------------------------

      crain_mm = dlinint(time,g%SWIMRainTime,g%SWIMRainAmt,
     :                       g%SWIMRainNumPairs)

      apswim_crain = crain_mm / 10d0

      return
      end function



* ====================================================================
       double precision function apswim_cevap (time)
* ====================================================================

      implicit none

*+  Sub-Program Arguments
       double precision time


*+  Constant Values
      double precision pi
      parameter (pi = 3.14159d0)

*+  Local Variables
       double precision cevap_mm        ! cumulative evaporation in mm
       integer          counter         ! simple counter variable
       double precision Timefr          ! fractional distance between
                                        ! evap time pointer
*- Implementation Section ----------------------------------
      cevap_mm = dlinint(time,g%SWIMEvapTime,g%SWIMEvapAmt,
     :                       g%SWIMEvapNumPairs)

      apswim_cevap = cevap_mm / 10d0

      return
      end function



*     ===========================================================
      double precision function dlinint (x, x_cord, y_cord, num_cord)
*     ===========================================================

      implicit none

*+  Sub-Program Arguments
      integer          num_cord         ! (INPUT) size_of of tables
      double precision x                ! (INPUT) value for interpolation
      double precision x_cord(num_cord) ! (INPUT) p%x co-ordinates of function
      double precision y_cord(num_cord) ! (INPUT) y co_ordinates of function

*+  Purpose
*       Linearly interpolates a value y for a given value x and a given
*       set of xy co-ordinates.
*       When x lies outside the x range, y is set to the boundary condition.
*       (This is a direct copy of linear_interp_real changed to double
*       precision)

*+  Assumptions
*       XY pairs are ordered by x in ascending order.

*+  Local Variables
      integer          indx        ! position in table
      double precision y           ! interpolated value

*- Implementation Section ----------------------------------

            ! find where p%x lies in the p%x cord


      do 100 indx = 1, num_cord
         if (x.le.x_cord(indx)) then

                  ! found position

            if (indx.eq.1) then

                     ! out of range

               y = y_cord(indx)

            else

                     ! interpolate - y = mx+c

               y = ddivide (y_cord(indx) - y_cord(indx-1)
     :                    , x_cord(indx) - x_cord(indx-1), 0.d0)
     :             * (x - x_cord(indx-1) )
     :             + y_cord(indx-1)
            endif

                  ! have a value now - exit_z

            goto 200

         else if (indx.eq.num_cord) then

                  ! not found - out of range

            y = y_cord(indx)

         else

                  ! position not found - keep looking

            y = 0.0
         endif

100   continue
200   continue

      dlinint = y

      return
      end function



*     ===========================================================
      double precision function ddivide (dividend, divisor, default)
*     ===========================================================


      implicit none

*+  Sub-Program Arguments
      double precision default     ! (INPUT) default value if overflow
      double precision dividend    ! (INPUT) dividend subroutine
      double precision divisor     ! (INPUT) divisor

*+  Purpose
*       Divides one number by another.  If the divisor is zero or overflow
*       would occur a specified default is returned.  If underflow would
*       occur, nought is returned.
*       This is adapted for double precision from 'divide'

*+  Assumptions
*       largest/smallest real number is 1.0e+/-30

*+  Changes
*       230994 nih adapted from divide

*+  Constant Values
      double precision largest     ! largest acceptable no. for quotient
      parameter (largest = 1d300)
*
      double precision nought      ! 0
      parameter (nought = 0d0)
*
      double precision smallest   ! smallest acceptable no. for quotient
      parameter (smallest = 1d-300)

*+  Local Variables
      double precision quotient    ! quotient

*- Implementation Section ----------------------------------


      if (dividend.eq.nought) then          ! multiplying by 0
         quotient = nought

      elseif (divisor.eq.nought) then       ! dividing by 0
         quotient = default

      elseif (abs (divisor).lt.1d0) then          ! possible overflow
         if (abs (dividend).gt.abs (largest*divisor)) then     ! overflow
            quotient = default
         else                               ! ok
            quotient = dividend/divisor
         endif

      elseif (abs (divisor).gt.1d0) then          ! possible underflow
         if (abs (dividend).lt.abs (smallest*divisor)) then     ! underflow
            quotient = nought
         else                               ! ok
            quotient = dividend/divisor
         endif

      else                                  ! ok
         quotient = dividend/divisor
      endif

      ddivide = quotient

      return
      end function



* ====================================================================
       double precision function apswim_time (yy,dd,tt)
* ====================================================================

      implicit none

*+  Sub-Program Arguments
      integer yy
      integer dd
      integer tt

*+  Constant Values
      double precision days_to_hours              ! convert .....
      parameter (days_to_hours = 24.d0)
*
      character myname*(*)               ! name of current procedure
      parameter (myname = 'apswim_time')

*+  Local Variables
      double precision begin_start_year
      double precision begin_year
      double precision julian_date
      double precision julian_start_date
      double precision time

*- Implementation Section ----------------------------------
      ! first we must calculate the julian date for the starting date.
      ! We will calculate time relative to this date.
      begin_Start_year = date_to_jday(1,1,g%start_year) - 1.d0
      julian_start_date = begin_start_year + dble(g%start_day) - 1.d0
*                                                              /
*                    all times are relative to beginning of the g%day
*

      begin_year = date_to_jday(1,1,yy) - 1.d0
      julian_date = begin_year + dble(dd) - 1.d0

      Time = (julian_date - julian_start_date)*days_to_hours +
     :                    dble(tt)/60.d0

      apswim_time = time

      return
      end function



* ====================================================================
       subroutine apswim_init_change_units ()
* ====================================================================

      implicit none

*+  Purpose
*   To keep in line with APSIM standard units we input many parameters
*   in APSIM compatible units and convert them here to SWIM compatible
*   units.

*+  Local Variables
      integer i
      integer num_nodes

*- Implementation Section ----------------------------------

      p%dtmin = p%dtmin/60.d0 ! convert to hours
      p%dtmax = p%dtmax/60.d0 ! convert to hours
      p%dw = p%dw / 10.d0 ! convert to cm

      p%grc = p%grc / 10.d0 ! convert mm to cm

      p%hm1 = p%hm1 / 10.d0 ! convert mm to cm
      p%hm0 = p%hm0 / 10.d0 ! convert mm to cm
      p%hrc = p%hrc / 10.d0 ! convert mm to cm
      g%hmin=g%hmin / 10.d0 ! convert mm to cm
      p%roff0 = p%roff0 * (10d0**p%roff1)/10.d0 ! convert (mm/h)/mm^P to
                                          ! (cm/h)/(cm^P)

      num_nodes = count_of_double_vals (p%dlayer(0),M+1)

      do 300 i=1,MV
         g%root_radius(:,i) = g%root_radius(:,i)/10d0
  300 continue

      return
      end subroutine



* ====================================================================
       double precision function apswim_eqrain (time)
* ====================================================================

      implicit none

*+  Sub-Program Arguments
      double precision time             ! first time (hours since start)

*- Implementation Section ----------------------------------

      apswim_eqrain = dlinint
     :                       (time
     :                       ,g%SWIMEqRainTime
     :                       ,g%SWIMEqRainAmt
     :                       ,g%SWIMRainNumPairs
     :                       )

      return
      end function


* ====================================================================
       subroutine apswim_read_solute_params ()
* ====================================================================

      implicit none

*+  Local Variables
       double precision temp(0:M)
       integer numvals
       integer solnum



*- Implementation Section ----------------------------------

      ! First - Read in solute information
            ! ----------------------------------

      call Read_double_var(
     :           solute_section,
     :           'dis',
     :           '()',
     :           p%dis,
     :           numvals,
     :           0d0,
     :           20d0)

      call Read_double_var(
     :           solute_section,
     :           'disp',
     :           '()',
     :           p%disp,
     :           numvals,
     :           0d0,
     :           5d0)
     
      call Read_double_var(
     :           solute_section,
     :           'a',
     :           '()',
     :           p%a,
     :           numvals,
     :           0d0,
     :           1d0)

      call Read_double_var(
     :           solute_section,
     :           'dthc',
     :           '(cm^3/cm^3)',
     :           p%dthc,
     :           numvals,
     :           0d0,
     :           1d0)

      call Read_double_var(
     :           solute_section,
     :           'dthp',
     :           '()',
     :           p%dthp,
     :           numvals,
     :           0d0,
     :           10d0)
     

      return
      end subroutine



* ====================================================================
       subroutine apswim_get_solute_variables ()
* ====================================================================

      implicit none

*+  Purpose
*      Get the values of solute variables from other modules

*+  Local Variables
      integer solnum                   ! solute array index counter
      integer node                     ! layer number specifier
      double precision solute_n(0:M)
                                       ! solute concn in layers(kg/ha)

*- Implementation Section ----------------------------------

      do 100 solnum = 1, p%num_solutes
         call apswim_conc_water_solute (p%solute_names (solnum)
     :                                 ,solute_n)
        do 50 node = 0, p%n
           g%csl(solnum,node) = solute_n(node)
   50   continue

  100 continue

      return
      end subroutine



* ====================================================================
       subroutine apswim_set_solute_variables ()
* ====================================================================

      implicit none

*+  Purpose
*      Set the values of solute variables from other modules

*+  Changes
*   21-6-96 NIH - Changed set_double_array to post construct
*   RCichota - 26/01/2010 - Add test to make sure SWIM will not send a -ve value
*   RCichota - 12/Jul/2010 - add simple test for -ve solution concentration

*+  Local Variables
      double precision Ctot
      double precision dCtot
      integer solnum                   ! solute array index counter
      integer node                     ! node number specifier
      double precision solute_n(0:M)   ! solute concn in layers(kg/ha)
      double precision dlt_solute_n(0:M)   ! solute concn in layers(kg/ha)
      character string*100
      type(NitrogenChangedType) :: ndata   ! structure holding NitrogenChanged data
      double precision dlt_solute_s(0:M-1) ! solute concn in layers(kg/ha)

*- Implementation Section ----------------------------------

      ! initialise the NitrogenChanged data to zero
      dlt_solute_s(:) = 0d0
      ndata%num_deltaurea = 0
      ndata%deltaurea = dlt_solute_s
      ndata%num_deltanh4 = 0
      ndata%deltanh4 = dlt_solute_s
      ndata%num_deltano3 = 0
      ndata%deltano3 = dlt_solute_s

      do 100 solnum = 1, p%num_solutes
         do 50 node=0,p%n
            ! Step One - calculate total solute in node from solute in
            ! water and Freundlich isotherm.

            if (g%csl(solnum,node).lt.0d0) then
               write(string,*)
     :               ' solution'
     :               ,p%solute_names(solnum)
     :               (:lastnb(p%solute_names(solnum)))
     :               ,'(',node,') = ',g%csl(solnum,node)
               call fatal_error (err_internal,
     :               '-ve concentration in apswim_set_solute_variables'
     :               //new_line//string)
            endif

            call apswim_freundlich (node,solnum,g%csl(solnum,node)
     :                    ,Ctot,dCtot)

            ! Note:- Sometimes small numerical errors can leave
            ! -ve concentrations. Test if values are within limits.

            if (abs(Ctot) .lt. 1d-100) then
               ! Ctot is REALLY small, its value can be disregarded
               ! set to zero to avoid underflow with reals

               Ctot = 0d0

            elseif (Ctot .lt. 0) then
               !Ctot is negative and a fatal error is thrown. Should not happen as it has been tested on apswim_freundlich
               write(string,'(x,3a,i3,a,G12.6)')
     :               '  Total '
     :               ,p%solute_names(solnum)
     :               (:lastnb(p%solute_names(solnum)))
     :               ,'(',node,') = ',Ctot
               call fatal_error(err_internal,
     :               '-ve value for solute concentration' 
     :               //new_line//string)

               Ctot = 0d0

            else
               ! Ctot is positive
            endif

            ! convert solute ug/cc soil to kg/ha for node
            !
            !  kg      ug        cc soil      kg
            !  -- = -------- p%x -------- p%x --
            !  ha    cc soil        ha        ug

            Ctot = Ctot                   ! ug/cc soil
     :           * (p%dx(node)*1d8)       ! cc soil/ha
     :           * 1d-9                   ! kg/ug

            ! finished testing - assign value to array element
            solute_n(node) = Ctot
            dlt_solute_n(node) = Ctot - g%cslstart(solnum,node)
            dlt_solute_s(node) = dlt_solute_n(node)

   50    continue

         ! Added by RCichota - using NitrogenChanged event to modify dlt_N's
         if (p%solute_names(solnum) .eq. 'urea') then
            ndata%num_deltaurea = p%n+1
            ndata%deltaurea = dlt_solute_s
         elseif (p%solute_names(solnum) .eq. 'nh4') then
            ndata%num_deltanh4 = p%n+1
            ndata%deltanh4 = dlt_solute_s
         elseif (p%solute_names(solnum) .eq. 'no3') then
            ndata%num_deltano3 = p%n+1
            ndata%deltano3 = dlt_solute_s
         else
            call Set_double_array (
     :              g%solute_owners(solnum),
     :              'dlt_'//p%solute_names(solnum),
     :              '(kg/ha)',
     :              dlt_solute_n(0),
     :              p%n+1)
         endif

  100 continue

      ! Send a NitrogenChanged event to the system
      ndata%sender = 'SWIM'
      ndata%sendertype = 'WaterModule'
      call publish_NitrogenChanged(ID%NitrogenChanged, ndata)

	   return
      end subroutine




* ====================================================================
       subroutine apswim_assign_crop_params (vegnum)
* ====================================================================

      implicit none


*+  Local Variables
       integer vegnum
       integer vegnum2

       logical found

*- Implementation Section ----------------------------------

      ! Now find what crops are out there and assign them the relevant
      ! ----------------------------------------------------------------
      !                   uptake parameters
      !                   -----------------

!      do 50 vegnum = 1,MV
!         g%psimin(vegnum) = 0d0
!         g%root_radius(vegnum) = 0d0
!         g%root_conductance(vegnum) = 0d0
!   50 continue

!      do 200 vegnum = 1,g%num_crops
!         found = .false.
         do 150 vegnum2 = 1, MV
           if (strings_equal(c%crop_table_name(vegnum2), 
     :                       g%crop_names(vegnum))) then
             found = .true.
             g%psimin(vegnum) = c%crop_table_psimin(vegnum2)
             g%root_radius(:,vegnum) = c%crop_table_root_radius(vegnum2)
     :                             /10d0 ! convert mm to cm
             g%root_conductance(:,vegnum)
     :             = c%crop_table_root_con(vegnum2)
           else
           endif
  150    continue

         if (.not.found) then
            call warning_error(Err_Internal,
     :        'Using default root parameters for '
     :         //g%crop_names(vegnum))
   
         do 160 vegnum2 = 1, MV
           if (c%crop_table_name(vegnum2).eq.'default') then
             found = .true.
             g%psimin(vegnum) = c%crop_table_psimin(vegnum2)
             g%root_radius(:,vegnum) = c%crop_table_root_radius(vegnum2)
     :                             /10d0 ! convert mm to cm
             g%root_conductance(:,vegnum)
     :             = c%crop_table_root_con(vegnum2)
           else
           endif
  160    continue

            if (.not.found) then
               call fatal_error(Err_Internal,
     :        'Could not find default root parameters')
            endif
         else
         endif

  200 continue

      return
      end subroutine

*     ===========================================================
      subroutine apswim_OnNewCrop (variant, fromID)
*     ===========================================================

      implicit none
      integer, intent(in) :: variant
      integer, intent(in) :: fromID

*+  Purpose
*       Register presence of a new crop

*+  Local Variables
      type(NewCropType) :: new_crop

      integer    numvals               ! number of values read
      integer    i
      integer    senderIdx
*- Implementation Section ----------------------------------


      call unpack_newcrop(variant, new_crop)

      ! See if we know of it
      senderIdx = 0
      do 100 i = 1, g%Num_Crops
        if (g%crop_owners(i).eq.new_crop%sender .and.
     :      g%crop_names(i).eq.new_crop%crop_type)
     :            senderIdx = i
 100  continue

      ! If sender is unknown, add it to the list
      
      if (senderIdx.eq.0) then
         g%Num_Crops = g%Num_Crops + 1
         g%nveg = g%num_crops
         if (g%num_crops.gt.MV) then
            call fatal_Error(ERR_Internal
     :                   ,'Too many crops in the system for swim')
         else
            g%crop_owners(g%Num_Crops) = new_crop%sender
            g%crop_names(g%Num_Crops) = new_crop%crop_type
            g%crop_owner_id(g%Num_Crops) = fromID
            g%crop_in(g%Num_Crops) = .true.

          ! Read Component Specific Constants
          ! ---------------------------------
            call apswim_assign_crop_params (g%Num_Crops)
            call apswim_register_crop_outputs(g%Num_Crops)
         
         endif
      else
         g%crop_in(senderIdx) = .true.
      endif

      return
      end subroutine

*     ===========================================================
      subroutine apswim_OnCropEnding (variant)
*     ===========================================================

      implicit none
      integer, intent(in) :: variant

*+  Purpose
*       Register ending of a crop

*+  Local Variables
      type(NewCropType) :: new_crop


      integer    i

*- Implementation Section ----------------------------------


      call unpack_newcrop(variant, new_crop)


      do 100 i = 1, g%Num_Crops
        if (g%crop_owners(i).eq.new_crop%sender) then
           g%crop_in(i) = .false.
        endif

 100  continue


      return
      end subroutine

*     ===========================================================
      subroutine apswim_OnCohortWaterDemand (variant, fromID)
*     ===========================================================

      implicit none
      integer, intent(in) :: variant
      integer, intent(in) :: fromID

*+  Purpose
*       Recieve water demand of a plant cohort within a crop

*+  Local Variables
      type(CohortWaterDemandType) :: demand

      integer    numvals               ! number of values read
      integer    i
      integer    senderIdx
      integer    cohortIdx
      integer    cropNo
      double precision length
      character  buffer*100
*- Implementation Section ----------------------------------

      call unpack_cohortwaterdemand(variant, demand)
      
! See whether this is the first time we've encountered this crop/cohort combination      
      senderIdx = 0
      cropNo = 0
      ! Find the first entry for this crop/pasture component
      do i = 1, g%Num_Crops
        if (g%crop_owner_id(i).eq.fromID .and.
     :      senderIdx.eq.0)
     :     senderIdx = i
        
      ! Find the crop/cohort combination
        if (g%crop_owner_id(i).eq.fromID .and.
     :      g%crop_names(i).eq.demand%cohortID)
     :         cropNo = i
      end do
      
      if (senderIdx .eq. 0) then
            call fatal_Error(ERR_Internal
     :         ,'Unexpected CohortWaterDemand event in SWIM')
            return
      endif
     
      ! If sender is unknown, add it to the list
      if (cropNo.eq.0) then

         ! If this is the first entry for the crop, and it hasn't already been converted to
         ! a cohort, do so now. Otherwise, add a new entry
         if (g%supply_event_id(senderIdx).eq.0) then
           cropNo = senderIdx
         else
           if (g%num_crops.ge.MV) then
              call fatal_Error(ERR_Internal
     :                     ,'Too many crops in the system for swim')
              return
           endif
           g%Num_Crops = g%Num_Crops + 1
           cropNo = g%Num_Crops
           g%nveg = g%num_crops
           g%crop_owners(cropNo) = g%crop_owners(senderIdx)
           g%crop_owner_id(cropNo) = fromID
           g%crop_in(cropNo) = .true.
         endif
         
         g%crop_names(cropNo) = demand%cohortID

         g%supply_event_id(cropNo) = add_reg_to_dest(eventReg, 
     :                 fromID, 
     :                 'CohortWaterSupply', 
     :                 CohortWaterSupplyTypeDDML)
          ! Read Component Specific Constants
          ! ---------------------------------
          call apswim_assign_crop_params (g%Num_Crops)
          call apswim_register_crop_outputs(g%Num_Crops)
         
      endif

      g%pep(cropNo) = demand%Demand / 10.0 !! convert kg/m^2 to cm
      g%psimin(cropNo) = demand%PsiXylemMin * 1.0d4 !! convert MPa to cm (approximately; use 10197 for more precision)
      g%demand_received(cropNo) = .true.

      if (demand%num_RootSystemLayer .gt. 0) then
        length = 0d0
        do i = 1, demand%num_RootSystemLayer
          !! Should check number of layers
          !! Could also check to be sure layer depths are as expected
          !! We also receive ll and kl. Are they of any use?
        
          g%rld(i-1, cropNo) = 
     :      demand%RootSystemLayer(i)%RootLengthDensity * 1.0d-4    !! Convert m/m^3 to cm/cm^3
          ! If a root radius is provided, use it
          if (demand%RootSystemLayer(i)%RootRadius .gt. 0.0) then
            g%root_radius(i-1, cropNo) = 
     :        demand%RootSystemLayer(i)%RootRadius * 1.0d-1    !! Convert mm to cm
          endif
     
          ! If a root conductance is provided, use it
          if (demand%RootSystemLayer(i)%RootConductance .gt. 0.0) then
            g%root_conductance(i-1, cropNo) = 
     :         demand%RootSystemLayer(i)%RootConductance
          endif
          
          length = length + 
     :        demand%RootSystemLayer(i)%RootLengthDensity * 1.0d-6 * !! Convert m/m^3 to mm/mm^3
     :        p%dlayer(i-1)
        enddo
        if ((length.gt.0.).and.
     :      (length.lt.c%min_total_root_length)) then
          call warning_error(Err_Internal,
     :        'Possible error with low total RLV for '
     :         //g%crop_owners(cropNo)//':'//g%crop_names(cropNo))
        endif
      endif  

      return
      end subroutine


* ====================================================================
       subroutine apswim_register_crop_outputs (vegnum)
* ====================================================================

      implicit none

*+  Purpose
*     Register any crop related output variables

*+  Local Variables
      integer id
      integer vegnum
      integer solnum
      character Variable_name*64
      character cropname*50

*- Implementation Section ----------------------------------
      if (g%supply_event_id(vegnum) .EQ. 0) then
        cropname = g%crop_names(vegnum)
      else
        cropname = trim(g%crop_owners(vegnum))//
     :                   '_'//trim(g%crop_names(vegnum))
      endif
      variable_name = 'uptake_water_'//trim(cropname)
      id = add_reg (respondToGetReg, Variable_name,
     :                       DoubleArrayTypeDDML, 'mm', '')

      do solnum = 1, p%num_solutes
         variable_name = 'supply_'//trim(p%solute_names(solnum))
     :            //'_'//trim(cropname)
         id = add_reg (respondToGetReg, Variable_name,
     :                       DoubleArrayTypeDDML, 'kg/ha', '')
      end do

!      do vegnum = 1, g%num_crops
!         do solnum = 1, p%num_solutes

!            variable_name = 'uptake_'//trim(p%solute_names(solnum))
!     :                       //'_'//trim(g%crop_names(vegnum))
!            id = Add_Registration (respondToGetSetReg, Variable_name,
!     :                       DoubleArrayTypeDDML, ' ')

!         end do
!      end do

      return
      end subroutine

* ====================================================================
       subroutine apswim_register_solute_outputs ()
* ====================================================================

      implicit none

*+  Local Variables
      integer id
      integer solnum
      character Variable_name*64
      character DDML*128

*- Implementation Section ----------------------------------

      do solnum = 1, p%num_solutes
            DDML = '<type name="solute_flow" array="T"'
     :           //' kind="double" unit="kg/ha"/>'
            variable_name = 'flow_'//trim(p%solute_names(solnum))
            id = Add_Registration (respondToGetReg, Variable_name,
     :                       DDML, ' ')

            DDML = '<type name="solute_leach" array="F"'
     :           //' kind="double" unit="kg/ha"/>'
            variable_name = 'leach_'//trim(p%solute_names(solnum))
            id = Add_Registration (respondToGetReg, Variable_name,
     :                       DDML, ' ')

            DDML = '<type name="solute_exco" array="T"'
     :           //' kind="double" unit=""/>'
            variable_name = 'exco_'//trim(p%solute_names(solnum))
            id = Add_Registration (respondToGetSetReg, Variable_name,
     :                       DDML, ' ')

            DDML = '<type name="conc_water_solute" array="T"'
     :           //' kind="double" unit="ppm"/>'
            variable_name = 'conc_water_'//trim(p%solute_names(solnum))
            id = Add_Registration (respondToGetReg, Variable_name,
     :                       DDML, ' ')

            DDML = '<type name="conc_adsorb_solute" array="T"'
     :           //' kind="double" unit="ppm"/>'
            variable_name = 'conc_adsorb_'//trim(p%solute_names(solnum))
            id = Add_Registration (respondToGetReg, Variable_name,
     :                       DDML, ' ')

            DDML = '<type name="subsurface_drain_solute" array="F"'
     :           //' kind="double" unit="kg/ha"/>'
            variable_name = 'subsurface_drain_'//
     :                          trim(p%solute_names(solnum))
            id = Add_Registration (respondToGetReg, Variable_name,
     :                       DDML, ' ')

      end do

      return
      end subroutine

* ====================================================================
       subroutine apswim_get_crop_variables ()
* ====================================================================


      implicit none

*+  Purpose
*      Get the values of solute variables from other modules

*+  Changes
*     <insert here>

*+  Calls


*+  Local Variables
      double precision rlv_l(M+1)
      double precision rrh(M+1)
      double precision pep
      integer vegnum                   ! solute array index counter
      integer layer                    ! layer number specifier
      integer numvals                  ! number of values returned
      double precision bare            ! amount of bare area
      integer crop                     ! crop number
      integer   solnum                 ! solute number for array index
      character solute_demand_name*(strsize)  ! key name for solute demand
      double precision length          ! total length of roots for a plant (mm/mm2)

      integer id
      logical OK

*- Implementation Section ----------------------------------

      bare = 1.0

      do 100 vegnum = 1, g%num_crops

         if (g%crop_in(vegnum)) then

         id = g%crop_owner_id(vegnum)
                  
         g%demand_received(vegnum) = .false.
         pep = 0.0
         call get_double_var_optional (
     :           id,
     :           'sw_demand',
     :           '(mm)',
     :           pep,
     :           numvals,
     :           0d0,
     :           20d0)
         if (numvals.eq.0) then
            call get_double_var (
     :              id,
     :              'WaterDemand',
     :              '(mm)',
     :              pep,
     :              numvals,
     :              0d0,
     :              20d0)

         endif

         ! Use the returned value only if we didn't also receive a CohortWaterDemand event
         if (.not. g%demand_received(vegnum)) then


           if (numvals.gt.0) then
              g%pep(vegnum) = pep/10d0 ! convert mm to cm

           else
              call fatal_error (Err_Internal,
     :          'no sw demand returned from '//g%crop_names(vegnum))
           endif


             call get_double_array_optional(
     :               id,
     :               'relativeroothealth',
     :               p%n+1,
     :               '(0-1)',
     :               rrh,
     :               numvals,
     :               0d0,
     :               1d0)
            if (numvals.eq.0) then
               do 10 layer = 1,M+1
                  rrh(layer) = 1d0
   10          continue
            endif
            
           ! Initialise tempory varaibles to zero
             do 11 layer = 1,M+1
                rlv_l(layer) = 0d0
   11        continue
     
             call get_double_array_optional(
     :               id,
     :               'rlv',
     :               p%n+1,
     :               '(mm/mm^3)',
     :               rlv_l,
     :               numvals,
     :               0d0,
     :               1d0)
             if (numvals.eq.0) then
             call get_double_array (
     :               id,
     :               'rootlengthdensity',
     :               p%n+1,
     :               '(mm/mm^3)',
     :               rlv_l,
     :               numvals,
     :               0d0,
     :               1d0)


             endif
             
             
             if (numvals.gt.0) then            !  convert mm/mm^3 to cm/cc
                length = 0d0
                do 60 layer = 1,p%n+1            !       /
                   g%rld(layer-1,vegnum) = rlv_l(layer)*100d0*rrh(layer)
                   length = length + rlv_l(layer) * p%dlayer(layer-1)
   60           continue
                if ((length.gt.0.).and.
     :              (length.lt.c%min_total_root_length)) then
                   call warning_error(Err_Internal,
     :            'Possible error with low total RLV for '
     :             //g%crop_names(vegnum))
                endif
             else
                call fatal_error (Err_Internal,
     :            'no rlv returned from '//g%crop_names(vegnum))
           endif
         endif

         call get_double_var (
     :           id,
     :           'height',
     :           '(mm)',
     :           g%canopy_height(vegnum),
     :           numvals,
     :           0d0,
     :           50d3)

         call get_double_var (
     :           id,
     :           'cover_tot',
     :           '()',
     :           g%cover_tot(vegnum),
     :           numvals,
     :           0d0,
     :           1d0)
         bare = bare * (1d0 - dble(g%cover_tot(vegnum)))

         do 99 solnum = 1, p%num_solutes

            solute_demand_name = string_concat(p%solute_names(solnum),
     :                                         '_demand')
            call get_double_var_optional (
     :           id,
     :           solute_demand_name,
     :           '(kg/ha)',
     :           g%solute_demand (vegnum,solnum),
     :           numvals,
     :           0d0,
     :           1000d0)

   99    continue

         else
            g%rld(:,vegnum)=0.0
            g%pep(vegnum) = 0.0
            g%canopy_height(vegnum) = 0.0
            g%cover_tot(vegnum) = 0.0
            g%solute_demand (vegnum,:)=0.0
         endif
         
  100 continue

      g%crop_cover = 1.0 - bare
      

      return
      end subroutine



* ====================================================================
       subroutine apswim_ONirrigated ()
* ====================================================================


      implicit none

*+  Purpose
*     <insert here>

*+  Assumptions
*   That g%day and g%year have already been updated before entry into this
*   routine. e.g. Prepare stage executed already.

*+  Changes
*   neilh - 19-01-1995 - Programmed and Specified
*   neilh - 28-05-1996 - Added call to get_other_variables to make
*                        sure g%day and g%year are up to date.
*      21-06-96 NIH Changed extract calls to collect calls
*   neilh - 22-07-1996 removed data_String from arguments
*   neilh - 29-08-1997 added test for whether directives are to be echoed

*+  Calls


*+  Constant Values
      character myname*(*)               ! name of current procedure
      parameter (myname = 'apswim_ONirrigated')

*+  Local Variables
       integer          counter
       double precision amount
       double precision duration
       double precision intensity
       double precision check_amount
       integer          numvals_int
       integer          numvals_dur
       integer          numvals_amt
       integer          numvals
       double precision solconc
       integer          solnum
       integer          time_mins
       character        time_string*10
       double precision irrigation_time
       double precision TEMPSolTime(SWIMLogSize)
       double precision TEMPSolAmt(SWIMLogSize)
       integer          TEMPSolNumPairs

*- Implementation Section ----------------------------------
      call push_routine (myname)

      if (p%echo_directives.eq.'on') then
         ! flag this event in output file
         call Write_string ('APSwim adding irrigation to log')
      else
      endif

      call collect_char_var (
     :                         DATA_irrigate_time
     :                        ,'(hh:mm)'
     :                        ,time_string
     :                        ,numvals)


      call collect_double_var_optional (
     :                         DATA_irrigate_amount
     :                        ,'(mm)'
     :                        ,amount
     :                        ,numvals_amt
     :                        ,0.d0
     :                        ,1000.d0)

      call collect_double_var_optional (
     :                         DATA_irrigate_duration
     :                        ,'(min)'
     :                        ,duration
     :                        ,numvals_dur
     :                        ,0.d0
     :                        ,24d0*60d0)

cnh NOTE - intensity is not part of the official design !!!!?
      call collect_double_var_optional (
     :                         'intensity'
     :                        ,'(mm/h)'
     :                        ,intensity
     :                        ,numvals_int
     :                        ,0.d0
     :                        ,24d0*60d0)


      if ((numvals_int.ne.0).and.(numvals_dur.ne.0)
     :       .and.(numvals_amt.ne.0)) then
         ! the user has specified all three
         check_amount = intensity/60d0*duration

         if (abs(amount-check_amount).ge.1.) then
            call fatal_error (ERR_User,
     :         'Irrigation information error greater than 1 mm'//
     :         '(ie amount not equal to intensity/60*duration)')

         elseif (abs(amount-check_amount).ge.0.1) then
            call warning_error (ERR_User,
     :         'Irrigation information error greater than .1 mm'//
     :         '(ie amount not equal to intensity/60*duration)')

         else
         endif

      elseif ((numvals_amt.ne.0).and.(numvals_dur.ne.0)) then
         ! We have all the information we require - do nothing

      elseif ((numvals_int.ne.0).and.(numvals_dur.ne.0)) then
         ! we need to calculate the amount
         amount = intensity/60d0*duration

      elseif ((numvals_int.ne.0).and.(numvals_amt.ne.0)) then
         ! we need to calculate the duration
         duration = ddivide (amount,intensity/60d0,0.d0)
      else
         ! We do not have enough information
         call fatal_error (ERR_User,
     :     'Incomplete Irrigation information')

         !  set defaults to allow completion
         amount = 0.0
         duration = 1.0

      endif

      ! get information regarding time etc.
      call apswim_Get_other_variables()

      time_mins = apswim_time_to_mins (time_string)
      irrigation_time = apswim_time (g%year,g%day,time_mins)

      ! allow 1 sec numerical error as data resolution is
      ! 60 sec.
      if (irrigation_time.lt.(g%t - 1.d0/3600.d0) )then

         call fatal_error (ERR_User,
     :                    'Irrigation has been specified for an '//
     :                    'already processed time period')
      else
      endif


      call apswim_insert_loginfo (
     :                         irrigation_time
     :                        ,duration
     :                        ,amount
     :                        ,g%SWIMRainTime
     :                        ,g%SWIMRainAmt
     :                        ,g%SWIMRainNumPairs
     :                        ,SWIMLogSize)

      call apswim_recalc_eqrain ()

      do 100 solnum = 1, p%num_solutes
         call collect_double_var_optional (
     :                         p%solute_names(solnum)
     :                        ,'(kg/ha)'
     :                        ,solconc
     :                        ,numvals
     :                        ,c%lb_solute
     :                        ,c%ub_solute)

        if (numvals.gt.0) then
           TEMPSolNumPairs = g%SWIMSolNumPairs(solnum)
           do 50 counter = 1, TEMPSolNumPairs
              TEMPSolTime(counter) = g%SWIMSolTime(solnum,counter)
              TEMPSolAmt(counter) = g%SWIMSolAmt(solnum,counter)
   50      continue

           call apswim_insert_loginfo (
     :                         irrigation_time
     :                        ,duration
     :                        ,solconc
     :                        ,TEMPSolTime
     :                        ,TEMPSolAmt
     :                        ,TEMPSolNumPairs
     :                        ,SWIMLogSize)

           g%SWIMSolNumPairs(solnum) = TEMPSolNumPairs
           do 60 counter = 1, TEMPSolNumPairs
              g%SWIMSolTime(solnum,counter) = TEMPSolTime(counter)
              g%SWIMSolAmt(solnum,counter) = TEMPSolAmt(counter)
   60      continue

        else
        endif
  100 continue

      call pop_routine (myname)
      return
      end subroutine

* ====================================================================
       subroutine apswim_OnSubSurfaceFlow ()
* ====================================================================

      implicit none

*+  Local Variables
      double precision amount(0:m)
      integer          numvals
*- Implementation Section ----------------------------------

      if (p%echo_directives.eq.'on') then
         ! flag this event in output file
         call Write_string ('APSwim adding sub-surface water flow')
      else
      endif

      call collect_double_array (
     :              'amount',
     :              p%n+1,
     :              '(mm)',
     :              amount(0),
     :              numvals,
     :              0d0,
     :              1000d0)

      g%SubSurfaceInflow(0:numvals) = g%SubSurfaceInflow(0:numvals)
     :                             + amount(0:numvals)

      return
      end subroutine


* ====================================================================
       double precision function apswim_csol (solnum,time)
* ====================================================================


      implicit none

*+  Sub-Program Arguments
       integer          solnum
       double precision time

*+  Purpose
*        cumulative solute in ug/cm^2

*+  Changes
*   NeilH - 29-09-1994 - Programmed and Specified

*+  Calls


*+  Constant Values
      character myname*(*)               ! name of current procedure
      parameter (myname = 'apswim_csol')

*+  Local Variables
       double precision Samount (SWIMLogSize)
       integer          counter
       double precision STime(SWIMLogSize)

*- Implementation Section ----------------------------------
      call push_routine (myname)

      do 100 counter=1,g%SWIMSolNumPairs(solnum)
         SAmount(counter) = g%SWIMSolAmt (solnum,counter)
         STime (counter) = g%SWIMSolTime (solnum,counter)
  100 continue

      ! Solute arrays are in kg/ha of added solute.  From swim's equations
      ! with everything in cm and ug per g water we convert the output to
      ! ug per cm^2 because the cm^2 area and height in cm gives g water.
      ! There are 10^9 ug/kg and 10^8 cm^2 per ha therefore we get a
      ! conversion factor of 10.

      apswim_csol = dlinint(time,STime,SAmount
     :                 , g%SWIMSolNumPairs(solnum))
     :            * 10d0

      call pop_routine (myname)
      return
      end function



* ====================================================================
       subroutine apswim_get_sw_uptake (ucrop, uarray,uflag)
* ====================================================================


      implicit none

*+  Sub-Program Arguments
      double precision uarray(0:p%n)
      character ucrop *(*)
      logical   uflag

*+  Constant Values
      character myname*(*)               ! name of current procedure
      parameter (myname = 'apswim_get_sw_uptake')

*+  Local Variables
      integer counter
      integer node
      integer vegnum
      character cropname*50
 
*- Implementation Section ----------------------------------

      uflag = .false.
      call fill_double_array (uarray(0), 0d0, p%n+1)

      vegnum = 0
      do 10 counter = 1, g%num_crops
         if (g%supply_event_id(counter) .EQ. 0) then
            cropname = g%crop_names(counter)
         else
            cropname = trim(g%crop_owners(counter))//
     :                   '_'//trim(g%crop_names(counter))
         endif
         if (strings_equal(ucrop, cropname)) vegnum = counter
   10 continue

      if (vegnum.eq.0) then
         ! ignore it

      else
         uflag = .true.
          do 40 node=0,p%n
             ! uptake may be very small -ve - assume error small
             uarray(node) = max (g%pwuptake(vegnum,node),0d0)
   40     continue

      endif

      return
      end subroutine

* ====================================================================
      subroutine PublishUptakes()
* ====================================================================

      implicit none
      integer counter
      integer node
      type(WaterUptakesCalculatedType) :: Water
      type(CohortWaterSupplyType) :: Supply
      character CropName*200
      double precision bottom

      Water%num_Uptakes = 0

      do counter = 1, g%num_crops

         if (g%supply_event_id(counter) .ne. 0) then
           Supply%CohortID = g%crop_names(counter)
           Supply%num_RootSystemLayer = p%n+1
           bottom = 0.0
           do node=0, p%n
              ! This uses "bottom", not "dlayer", so we need to convert
              bottom = bottom + p%dlayer(node)
              Supply%RootSystemLayer(node+1)%Bottom = bottom
              
              ! uptake may be very small -ve - assume error small
              Supply%RootSystemLayer(node+1)%Supply =
     .              max(g%pwuptake(counter,node),0d0)
           end do

           call publish_CohortWaterSupply
     .        (g%supply_event_id(counter), Supply);
         endif
         
         if (g%supply_event_id(counter) .EQ. 0) then
            cropname = g%crop_owners(counter)
         else
            cropname = trim(g%crop_owners(counter))//
     :                   '_'//trim(g%crop_names(counter))
         endif

         Water%num_Uptakes = Water%num_Uptakes + 1
         Water%Uptakes(counter)%Name = CropName
         Water%Uptakes(counter)%Num_amount = p%n+1

         do node=0, p%n
            ! uptake may be very small -ve - assume error small
            Water%Uptakes(counter)%Amount(node+1) =
     .            max(g%pwuptake(counter,node),0d0)

         end do
      end do

      call publish_WaterUptakesCalculated
     .     (id%WaterUptakesCalculated, Water);

      end subroutine
* ====================================================================
       subroutine apswim_get_supply (ucrop, uname, uarray, uunits,uflag)
* ====================================================================


      implicit none

*+  Sub-Program Arguments
      double precision uarray(0:p%n)
      character ucrop *(*)
      character uname *(*)
      character uunits*(*)
      logical       uflag

*+  Constant Values
      character myname*(*)               ! name of current procedure
      parameter (myname = 'apswim_get_supply')

*+  Local Variables
      integer counter
      integer node
      integer solnum
      integer vegnum
      character cropname*50

*+  Initial Data Values
      uflag = .false. ! set to false to start - if match is found it is
                      ! set to true.
      uunits = ' '

*- Implementation Section ----------------------------------
      call push_routine (myname)

      call fill_double_array (uarray(0), 0d0, p%n+1)

      vegnum = 0
      do 10 counter = 1, g%num_crops
         if (g%supply_event_id(counter) .EQ. 0) then
            cropname = g%crop_names(counter)
         else
            cropname = trim(g%crop_owners(counter))//
     :                   '_'//trim(g%crop_names(counter))
         endif
         if (ucrop .eq. cropname) vegnum = counter
   10 continue

      if (vegnum.eq.0) then
         ! ignore it

      else

         if (uname.eq.'water') then
             uflag = .true.
             uunits = '(mm)'
             do 40 node=0,p%n
                ! uptake may be very small -ve - assume error small
                uarray(node) = max (g%pwuptakepot(vegnum,node),0d0)
   40        continue

         else
!            do 100 solnum = 1, p%num_solutes
!               if (p%solute_names(solnum).eq.uname) then
!                  do 50 node=0,p%n
!                     uarray(node) = max(g%psuptake(solnum,vegnum,node)
!     :                                 ,0d0)
!   50             continue
!                  uflag = .true.
!                  uunits = '(kg/ha)'
!                  goto 110
!               else
!               endif
!  100       continue
!  110       continue
             uflag = .false.

         endif
      endif

      call pop_routine (myname)
      return
      end subroutine


*     ===========================================================
      double precision function dubound (var, upper)
*     ===========================================================


      implicit none

*+  Sub-Program Arguments
      double precision upper        ! (INPUT) upper limit of variable
      double precision var          ! (INPUT) variable to be constrained

*+  Purpose
*       constrains a variable to upper bound of upper
*       Adapted from u_bound (real)

*+  Changes
*       290994  nih adapted from u_bound

*- Implementation Section ----------------------------------

      dubound = min (var, upper)

      return
      end function



*     ===========================================================
      double precision function dlbound (var, lower)
*     ===========================================================


      implicit none

*+  Sub-Program Arguments
      double precision lower   ! (INPUT) lower limit of variable
      double precision var     ! (INPUT) variable to be constrained

*+  Purpose
*       constrains a variable to or above lower bound of lower
*       adapted from l_bound (real)

*+  Changes
*       290994 nih adapted from l_bound

*- Implementation Section ----------------------------------

      dlbound = max (var, lower)

      return
      end function



* ====================================================================
       integer function apswim_solute_number (solname)
* ====================================================================


      implicit none

*+  Sub-Program Arguments
       character solname*(*)

*+  Constant Values
      character myname*(*)               ! name of current procedure
      parameter (myname = 'apswim_solute_number')

*+  Local Variables
       integer counter
       integer solnum

*- Implementation Section ----------------------------------

      solnum = 0
      do 100 counter = 1, p%num_solutes
         if (p%solute_names(counter).eq.solname) then
            solnum = counter
         else
         endif
  100 continue

      apswim_solute_number = solnum

      return
      end function



* ====================================================================
       subroutine apswim_get_rain_variables ()
* ====================================================================

      implicit none

*+  Purpose
*      Get the rainfall values from other modules

*+  Changes
*    26/5/95 NIH - programmed and specified
*    24/6/98 NIH - added check for swim getting rainfall from itself

*+  Calls


*+  Local Variables
      integer numvals                  ! number of values returned
      double precision amount          ! amount of rainfall (mm)
      character time*6                 ! time of rainfall (hh:mm)
      double precision duration        ! duration of rainfall (min)
      double precision intensity       ! intensity of rainfall (mm/h)
      integer time_of_day              ! time of g%day (min)
      double precision time_mins       ! time of rainfall (min)
      integer owner_module             ! id of module providing info.
      integer this_module              ! id of this module

*- Implementation Section ----------------------------------

      call get_double_var (
     :           unknown_module,
     :           'rain',
     :           '(mm)',
     :           amount,
     :           numvals,
     :           0.d0,
     :           1000.d0)

      ! Check that apswim is not getting rainfall from itself.
      owner_module = get_posting_module ()
      this_module = get_componentID ()
      if (owner_module.eq.this_module) then
         call fatal_error (ERR_User,
     :      'No module provided rainfall values for APSwim')
         amount = 0.d0
      else
      endif

      time = ''
      call get_char_var_optional (
     :           unknown_module,
     :           'rain_time',
     :           '(hh:mm)',
     :           time,
     :           numvals)

      if (numvals.eq.0) then
         time = c%default_rain_time
         duration = c%default_rain_duration
      else

         call get_double_var_optional (
     :           unknown_module,
     :           'rain_durn',
     :           '(min)',
     :           duration,
     :           numvals,
     :           0.d0,
     :           1440.d0*30.d0)    ! one month of mins


         if (numvals.eq.0) then
            call get_double_var_optional (
     :           unknown_module,
     :           'rain_int',
     :           '(min)',
     :           intensity,
     :           numvals,
     :           0.d0,
     :           250.d0)          ! 10 inches in one hour

            if (numvals.eq.0) then
               call fatal_error (Err_User,
     :         'Failure to supply rainfall duration or intensity data')
            else
               Duration = ddivide (amount,intensity,0.d0) * 60.d0
            endif                                    !      /
                                               ! hrs->mins
         else
         endif
       endif


      if (amount.gt.0d0) then
         time_of_day = apswim_time_to_mins (time)
         Time_mins = apswim_time (g%year,g%day,time_of_day)
         call apswim_insert_loginfo (
     :                                time_mins
     :                               ,duration
     :                               ,amount
     :                               ,g%SWIMRainTime
     :                               ,g%SWIMRainAmt
     :                               ,g%SWIMRainNumPairs
     :                               ,SWIMLogSize)

      else
         ! No g%rain to add to record
      endif


      return
      end subroutine



*     ===========================================================
      subroutine apswim_pot_evapotranspiration (pot_eo)
*     ===========================================================

      implicit none

*+  Sub-Program Arguments
      double precision       pot_eo      ! (output) potential evapotranspiration

*+  Purpose
*       calculate potential evapotranspiration

*+  Local Variables
      double precision albedo          ! albedo taking into account plant
                                       !    material
      double precision surface_albedo  ! albedo of soil surface
      double precision eeq             ! equilibrium evaporation rate (mm)
      double precision wt_ave_temp     ! weighted mean temperature for the
                                       !    g%day (oC)

*- Implementation Section ----------------------------------


*  ******* calculate potential evaporation from soil surface (eos) ******

                ! find equilibrium evap rate as a
                ! function of radiation, albedo, and temp.

      surface_albedo = p%salb
     :       + (c%residue_albedo - p%salb) * g%residue_cover
      albedo = c%max_albedo
     :       - (c%max_albedo-surface_albedo) * (1d0-g%cover_green_sum)

                ! wt_ave_temp is mean temp, weighted towards max.

      wt_ave_temp = 0.6d0*g%maxt + 0.4d0*g%mint

      eeq = g%radn*23.8846d0* (0.000204d0 - 0.000183d0*albedo)
     :    * (wt_ave_temp + 29.d0)

                ! find potential evapotranspiration (pot_eo)
                ! from equilibrium evap rate

      pot_eo = eeq*apswim_eeq_fac ()

      return
      end subroutine



*     ===========================================================
      double precision function apswim_eeq_fac ()
*     ===========================================================


      implicit none

*+  Purpose
*                 calculate coefficient for equilibrium evaporation rate

*- Implementation Section ----------------------------------


      if (g%maxt.gt.c%max_crit_temp) then

                ! at very high max temps eo/eeq increases
                ! beyond its normal value of 1.1

         apswim_eeq_fac =  ((g%maxt - c%max_crit_temp) *0.05 + 1.1)
      else if (g%maxt.lt.c%min_crit_temp) then

                ! at very low max temperatures eo/eeq
                ! decreases below its normal value of 1.1
                ! note that there is a discontinuity at tmax = 5
                ! it would be better at tmax = 6.1, or change the
                ! .18 to .188 or change the 20 to 21.1

         apswim_eeq_fac = 0.01*exp (0.18* (g%maxt + 20.0))
      else

                ! temperature is in the normal range, eo/eeq = 1.1

         apswim_eeq_fac = 1.1
      endif

      end function



* ====================================================================
       subroutine apswim_read_constants ()
* ====================================================================

      implicit none

*+  Purpose
*      Read in all constants from constants file.

*+  Constant Values
*
       character section_name*(*)
       parameter (section_name = 'constants')

*+  Local Variables
       integer numvals                 ! number of values read from file
       integer solnum

*- Implementation Section ----------------------------------

      call Read_integer_var (
     :              section_name,
     :              'max_iterations',
     :              '()',
     :              c%max_iterations,
     :              numvals,
     :              1,
     :              100)

         ! Read in p%ersoil from parameter file

      call Read_double_var (
     :              section_name,
     :              'ersoil',
     :              '(??)',
     :              c%ersoil,
     :              numvals,
     :              1.0d-10,
     :              1.0d0)

         ! Read in p%ernode from parameter file

      call Read_double_var (
     :              section_name,
     :              'ernode',
     :              '(??)',
     :              c%ernode,
     :              numvals,
     :              1.0d-10,
     :              1.0d0)

         ! Read in p%errex from parameter file

      call Read_double_var (
     :              section_name,
     :              'errex',
     :              '(??)',
     :              c%errex,
     :              numvals,
     :              1.0d-10,
     :              1.0d0)

         ! Read in p%dppl from parameter file

      call Read_double_var (
     :              section_name,
     :              'dppl',
     :              '(??)',
     :              c%dppl,
     :              numvals,
     :              0.0d0,
     :              1.0d1)

         ! Read in p%dpnl from parameter file

      call Read_double_var (
     :              section_name,
     :              'dpnl',
     :              '(??)',
     :              c%dpnl,
     :              numvals,
     :              0.0d0,
     :              1.0d1)

      call Read_double_var (
     :              section_name,
     :              'negative_conc_warn',
     :              '()',
     :              c%negative_conc_warn,
     :              numvals,
     :              0d0,
     :              10d0)

      call Read_double_var(
     :           section_name,
     :           'slcerr',
     :           '()',
     :           c%slcerr,
     :           numvals,
     :           1d-8,
     :           1d-4)

      call Read_double_var (
     :              section_name,
     :              'negative_conc_fatal',
     :              '()',
     :              c%negative_conc_fatal,
     :              numvals,
     :              0d0,
     :              10d0)

       call Read_double_var (
     :              section_name,
     :              'min_crit_temp',
     :              '(oC)',
     :              c%min_crit_temp,
     :              numvals,
     :              -10d0,
     :              100d0)

      call Read_double_var (
     :              section_name,
     :              'max_crit_temp',
     :              '(oC)',
     :              c%max_crit_temp,
     :              numvals,
     :              -10d0,
     :              100d0)

      call Read_double_var (
     :              section_name,
     :              'max_albedo',
     :              '(oC)',
     :              c%max_albedo,
     :              numvals,
     :              -10d0,
     :              100d0)

      call Read_double_var (
     :              section_name,
     :              'residue_albedo',
     :              '()',
     :              c%residue_albedo,
     :              numvals,
     :              0d0,
     :              1d0)

      call Read_double_var (
     :              section_name,
     :              'min_total_root_length',
     :              '(mm/mm2)',
     :              c%min_total_root_length,
     :              numvals,
     :              0d0,
     :              10d0)

      call Read_char_array(
     :           section_name,
     :           'crop_name',
     :           MV,
     :           '()',
     :           c%crop_table_name,
     :           numvals)

      call Read_double_array(
     :           section_name,
     :           'min_xylem_potential',
     :           MV,
     :           '()',
     :           c%crop_table_psimin,
     :           numvals,
     :           -1d7,
     :           1d0)

      call Read_double_array(
     :           section_name,
     :           'root_radius',
     :           MV,
     :           '(mm)',
     :           c%crop_table_root_radius,
     :           numvals,
     :           1d-3,
     :           1d1)

      call Read_double_array(
     :           section_name,
     :           'root_conductance',
     :           MV,
     :           '()',
     :           c%crop_table_root_con,
     :           numvals,
     :           1d-10,
     :           1d-3)



      call Read_char_var (
     :              section_name,
     :              'cover_effects',
     :              '()',
     :              c%cover_effects,
     :              numvals)

      call Read_double_var (
     :              section_name,
     :              'a_to_evap_fact',
     :              '()',
     :              c%a_to_evap_fact,
     :              numvals,
     :              0d0,
     :              1d0)

      call Read_double_var (
     :              section_name,
     :              'canopy_eos_coef',
     :              '()',
     :              c%canopy_eos_coef,
     :              numvals,
     :              0d0,
     :              10d0)


      call read_double_array (section_name
     :                   , 'canopy_fact', max_table, '()'
     :                   , c%canopy_fact, c%num_canopy_fact
     :                   , 0d0, 1d0)

      call read_double_array (section_name
     :                   , 'canopy_fact_height', max_table, '(mm)'
     :                   , c%canopy_fact_height, numvals
     :                   , 0d0, 100000.0d0)
      if (numvals.ne. c%num_canopy_fact) then
         call fatal_error (err_user
     :                    , 'No. of canopy_fact coeffs do not match '
     :                    //'no. of canopy_fact_height coeffs.')
      else
         ! matching number of coeffs
      endif

      call read_double_var (section_name
     :                   , 'canopy_fact_default', '()'
     :                   , c%canopy_fact_default, numvals
     :                   , 0d0, 1d0)


      call Read_char_var (
     :              section_name,
     :              'default_rain_time',
     :              '()',
     :              c%default_rain_time,
     :              numvals)

      call Read_double_var (
     :              section_name,
     :              'default_rain_duration',
     :              '(min)',
     :              c%default_rain_duration,
     :              numvals,
     :              0d0,
     :              1440d0)

      call Read_char_var (
     :              section_name,
     :              'default_evap_time',
     :              '()',
     :              c%default_evap_time,
     :              numvals)

      call Read_double_var (
     :              section_name,
     :              'default_evap_duration',
     :              '(min)',
     :              c%default_evap_duration,
     :              numvals,
     :              0d0,
     :              1440d0)



      call Read_double_var (
     :              section_name,
     :              'lb_solute',
     :              '(kg/ha)',
     :              c%lb_solute,
     :              numvals,
     :              0d0,
     :              1d10)

      call Read_double_var (
     :              section_name,
     :              'ub_solute',
     :              '(kg/ha)',
     :              c%ub_solute,
     :              numvals,
     :               c%lb_solute,
     :               1d10)


      call Read_double_var (
     :              section_name,
     :              'hydrol_effective_depth',
     :              '(mm)',
     :              c%hydrol_effective_depth,
     :              numvals,
     :               0d0,
     :               1d4)
     
     
      return
      end subroutine



* ====================================================================
       subroutine apswim_get_green_cover (cover_green_sum)
* ====================================================================

      implicit none

*+  Local Variables
      double precision cover_green_sum
      double precision bare
      double precision cover
      integer crop
      integer numvals

*- Implementation Section ----------------------------------

      call get_double_var_optional (unknown_module
     :                                  , 'cover_green_sum', '()'
     :                                  , cover_green_sum, numvals
     :                                  , 0.d0, 1.d0)

      if (numvals.eq.0) then
             ! we have no canopy module - get all crops covers

         crop = 0
         bare = 1.d0
1000     continue
            crop = crop + 1
            call get_double_vars (crop, 'cover_green', '()'
     :                              , cover, numvals
     :                              , 0.d0, 1.d0)

               ! Note - this is based on a reduction of Beers law
               ! cover1+cover2 = 1 - exp (-(k1*lai1 + k2*lai2))
            if (numvals.ne.0) then
               bare = bare * (1.d0 - cover)
               goto 1000
            else
                  ! no more crops
               cover_green_sum = 1.d0 - bare
            endif
      else
         ! got green cover from canopy module
      endif

      return
      end subroutine



* ====================================================================
       subroutine apswim_calc_evap_variables ()
* ====================================================================

      implicit none

*+  Local Variables
      double precision amount
      double precision duration
      integer numvals
      character time*10
      integer time_of_day
      double precision time_mins

*- Implementation Section ----------------------------------

      if ( doubles_are_equal (g%apsim_timestep, 1440.d0) ) then
         ! timestep is 24 hours - OK

         ! calculate evaporation for entire timestep

         time = ''
         call get_char_var_optional (
     :           unknown_module,
     :           'eo_time',
     :           '(hh:mm)',
     :           time,
     :           numvals)

         if (numvals.eq.0) then
            time = c%default_evap_time
            duration = c%default_evap_duration
         else

            call get_double_var (
     :           unknown_module,
     :           'eo_durn',
     :           '(min)',
     :           duration,
     :           numvals,
     :           0.d0,
     :           1440.d0*30.d0)    ! one month of mins

         endif

         time_of_day = apswim_time_to_mins (time)
         Time_mins = apswim_time (g%year,g%day,time_of_day)

         call apswim_get_green_cover (g%cover_green_sum)
         call apswim_pot_evapotranspiration (Amount)

         call apswim_insert_loginfo (time_mins
     :                              ,duration
     :                              ,amount
     :                              ,g%SWIMEvapTime
     :                              ,g%SWIMEvapAmt
     :                              ,g%SWIMEvapNumPairs
     :                              ,SWIMLogSize)
      else
         call fatal_error (Err_User,
     :      'apswim can only calculate Eo for daily timestep')
      endif

      return
      end subroutine



* ====================================================================
       subroutine apswim_recalc_eqrain ()
* ====================================================================

      implicit none

*+  Local Variables
      double precision amount
      double precision duration
      integer counter
      double precision eqrain
      double precision avinten

*- Implementation Section ----------------------------------

      ! leave the first element alone to keep magnitude in order

      do 100 counter = 2, g%SWIMRainNumPairs
         amount   = (g%SWIMRainAmt(counter)
     :                -g%SWIMRainAmt(counter-1))/10d0
         duration = g%SWIMRainTime(counter)-g%SWIMRainTime(counter-1)
         avinten = ddivide (amount, duration, 0.d0)

         if (avinten .gt. 0.d0) then
            eqrain = (1d0+effpar*log(avinten/2.5d0))*amount
         else
            eqrain = 0.d0
         endif

         g%SWIMEqRainTime(counter) = g%SWIMRainTime(counter)
         g%SWIMEqRainAmt(counter)  = g%SWIMEqRainAmt(counter-1)
     :                           + eqrain

  100 continue

      return
      end subroutine



* ====================================================================
       subroutine apswim_tillage ()
* ====================================================================

      implicit none

*+  Local Variables
      double precision new_hm1
      double precision new_hm0
      double precision new_hrc
      double precision new_g1
      double precision new_g0
      double precision new_grc
*
      integer          numvals

*- Implementation Section ----------------------------------

      if (p%echo_directives.eq.'on') then
         ! flag this event in output file
         call Write_string ('APSwim responding to tillage')
      else
      endif

      ! all surface conditions decay to be calculated relative to now
      !tzero = g%t
      !eqr0 = apswim_eqrain (tzero)

      call collect_double_var_optional (
     :                         'hm1'
     :                        ,'(mm)'
     :                        ,new_hm1
     :                        ,numvals
     :                        ,0.d0
     :                        ,1000.d0)
      if (numvals.gt.0) then
         p%hm1 = new_hm1/10d0 ! convert mm to cm
      else
      endif

      call collect_double_var_optional (
     :                         'hm0'
     :                        ,'(mm)'
     :                        ,new_hm0
     :                        ,numvals
     :                        ,0.d0
     :                        ,1000.d0)
      if (numvals.gt.0) then
         p%hm0 = new_hm0/10d0 ! convert mm to cm
      else
      endif

      call collect_double_var_optional (
     :                         'hrc'
     :                        ,'(mm)'
     :                        ,new_hrc
     :                        ,numvals
     :                        ,0.d0
     :                        ,1000.d0)
      if (numvals.gt.0) then
         p%hrc = new_hrc/10d0 ! convert mm to cm
      else
      endif

      ! Now set current storage to max storage
      g%hmin = p%hm1

      call collect_double_var_optional (
     :                         'g1'
     :                        ,'(mm)'
     :                        ,new_g1
     :                        ,numvals
     :                        ,0.d0
     :                        ,1000.d0)
      if (numvals.gt.0) then
         p%g1 = new_g1
      else
      endif

      call collect_double_var_optional (
     :                         'g0'
     :                        ,'(mm)'
     :                        ,new_g0
     :                        ,numvals
     :                        ,0.d0
     :                        ,1000.d0)
      if (numvals.gt.0) then
         p%g0 = new_g0
      else
      endif

      call collect_double_var_optional (
     :                         'grc'
     :                        ,'(mm)'
     :                        ,new_grc
     :                        ,numvals
     :                        ,0.d0
     :                        ,1000.d0)
      if (numvals.gt.0) then
         p%grc = new_grc/10d0 ! convert mm to cm
      else
      endif

      ! Now set current surface conductance to max
      g%gsurf = p%g1

      return
      end subroutine



* ====================================================================
       subroutine apswim_reset_water_balance (wc_flag, water_content)
* ====================================================================

      implicit none

*+  Sub-Program Arguments
      integer          wc_flag           ! flag defining type of water
                                         ! content
      double precision water_content (0:M)

*+  Local Variables
      integer i                          ! node index counter

*- Implementation Section ----------------------------------

      do 25 i=0,p%n
         
         if (wc_flag.eq.1) then
            ! water content was supplied in volumetric SW
            ! so calculate matric potential
            
            g%th (i) = water_content(i)
            g%psi(i) = apswim_suction (i,g%th(i))

         else if (wc_flag.eq.2) then
            ! matric potential was supplied
            ! so calculate water content
            g%psi(i) = water_content(i)
            g%th (i) = apswim_theta (i, g%psi(i))
         else
            call fatal_error (Err_Internal,
     :         'Bad wc_type flag value')
         endif

         g%p (i) = apswim_pf (g%psi(i))

   25 continue

      g%wp = apswim_wpf ()

      return
      end subroutine



* ====================================================================
       double precision function apswim_theta (i,suction)
* ====================================================================

      implicit none

*+  Sub-Program Arguments
      integer i
      double precision suction

*+  Local Variables
      double precision thd
      double precision theta
      double precision hklg
      double precision hklgd

*- Implementation Section ----------------------------------

      call apswim_interp
     :           (i, suction, theta, thd, hklg, hklgd)

      apswim_theta = theta

      return
      end function



* ====================================================================
       subroutine union_double_arrays (a,na,b,nb,c,nc,nc_max)
* ====================================================================

      implicit none

*+  Sub-Program Arguments
       integer na,nb,nc,nc_max
       double precision a(*),b(*),c(*)

*+  Local Variables
       integer i
       integer j
       integer key (100)

*+  Initial Data Values
      nc = 0

*- Implementation Section ----------------------------------

      ! Put A into C
      ! ------------
      do 10 i=1, na
        if (nc.lt.nc_max) then
           nc=nc+1
           c(nc) = a(i)
        else
        endif
   10 continue


      ! Put B into C
      ! ------------
      do 20 i=1, nb
        if (nc.lt.nc_max) then
           nc=nc+1
           c(nc) = b(i)
        else
        endif
   20 continue

      call shell_sort_double (c,nc,key)

   21 continue
      ! to avoid updating the counter - VERY BAD PROGRAMMING (NIH)
      do 30 i=1, nc-1
         if (Doubles_are_equal(c(i),c(i+1))) then
            do 25 j=i+1,nc-1
               c(j) = c(j+1)
   25       continue
            c(nc) = 0d0
            nc = nc - 1
            goto 21
         else
         endif
   30 continue

      return
      end subroutine



*     ===========================================================
      SUBROUTINE Shell_sort_double (array, size_of, key)
*     ===========================================================


      implicit none

*+  Sub-Program Arguments
      integer     key(*)
      integer     size_of
      double precision   array(*)

*+  Purpose
*     Sorts size_of elements of array into ascending order, storing pointers
*     in Key to the original order.
*     SHELL, MODIFIED FRANK AND LAZARUS, CACM 3,20 (1960)
*     TO MAKE key TO ORIGINAL ORDER, USE NEGATIVE VALUE OF size_of
*     TO SORT INTEGERS, USE    INTEGER array, array_temp

*+  Changes
*      201093 jngh copied

*+  Local Variables
      integer     indx
      integer     upper_indx
      integer     counter
      integer     end
      integer     step
      integer     array_size
      logical     keeper
      integer     key_temp
      double precision array_temp

*- Implementation Section ----------------------------------

      step = abs (size_of)
      array_size = abs (size_of)

      keeper = size_of.lt.0
      if (keeper) then
         do 1000 indx  =  1, array_size
            key(indx) = indx
1000     continue
      else
      endif

2000  continue
      if (step.gt.1) then

         if (step.le.15) then
            step = 2*(step/4) + 1
         else
            step = 2*(step/8) + 1
         endif

         end = array_size - step
         counter = 1

3000     continue
         indx = counter

4000     continue
         upper_indx  =  indx + step
         if (array(indx).gt.array(upper_indx)) then

            array_temp = array(indx)
            array(indx) = array(upper_indx)
            array(upper_indx) =  array_temp

            if (keeper) then
               key_temp = key(indx)
               key(indx) = key(upper_indx)
               key(upper_indx) = key_temp
            else
            endif

            indx = indx - step
            if (indx.ge.1) then
               goto 4000
            else
            endif

         else
         endif

         counter = counter + 1
         if (counter.gt.end)  then
            goto 2000
         else
            goto 3000
         endif

      else
      endif

      return
      end subroutine



* ====================================================================
       subroutine apswim_hmin (deqrain, sstorage)
* ====================================================================

      implicit none

*+  Sub-Program Arguments
      double precision deqrain
      double precision sstorage

*+  Local Variables
      double precision decay_fraction
      double precision ceqrain

*- Implementation Section ----------------------------------

cnh      g%hmin=p%hm0
cnh      if(p%hrc.ne.0..and.ttt.gt.tzero)then
cnh         g%hmin=p%hm0+(p%hm1-p%hm0)*exp(-(eqrain(ttt)-eqr0)/p%hrc)
cnh         g%hmin=p%hm0+(p%hm1-p%hm0)*exp(-(apswim_eqrain(ttt)-eqr0)/p%hrc)
cnh      end if

      ! Ideally, if timesteps are small we could just use
      ! dHmin/dEqr = -1/p%hrc p%x (g%hmin - p%hm0)
      ! but because this is really just a linear approximation of the
      ! curve for longer timesteps we had better be explicit and
      ! calculate the difference from the exponential decay curve.

      if (p%hrc.ne.0) then
         ! first calculate the amount of Energy that must have been
         ! applied to reach the current g%hmin.

         decay_Fraction = ddivide(g%hmin-p%hm0,p%hm1-p%hm0,0d0)

         if (doubles_are_equal (decay_fraction, 0d0)) then
            ! the roughness is totally decayed
            sstorage = p%hm0
         else
            ceqrain = -p%hrc * log(decay_Fraction)

            ! now add rainfall energy for this timestep
            if (c%cover_effects.eq.'on') then
               ceqrain = ceqrain + deqrain * (1d0 - g%residue_cover)
            else
               ceqrain = ceqrain + deqrain
            endif

            ! now calculate new surface storage from new energy
            sstorage=p%hm0+(p%hm1-p%hm0)*exp(-ceqrain/p%hrc)
         endif
      else
         ! nih - commented out to keep storage const
         ! sstorage = p%hm0
      endif

      return
      end subroutine



* ====================================================================
       subroutine apswim_freundlich (node, solnum, Cw, Ctot, dCtot)
* ====================================================================

      implicit none

*+  Sub-Program Arguments
      integer node
      integer solnum
      double precision Cw
      double precision Ctot
      double precision dCtot
*+  Changes
*   RCichota - 30/Jan/2010 - implement test for -ve values passed in, test for linear isotherm
*                  and test for very small values (these were ammended in 10/Jul/2010)
*+  Local Variables
      character        string*100
*- Implementation Section ----------------------------------
      ! first make sure Cw has not been passed negative. Changes by RCichota, 30/jan/2010, ammended 09/Jul/2010
      
      if (abs(Cw) .lt. 1d-100) then
         ! Cw is zero or REALLY small and can be diregarded,
         !  set to zero to avoid underflow with reals

         Cw = 0
         Ctot = 0d0
         dCtot = g%th(node)   !if n<1 it actually equals infinity at Cw = zero
                                 !this value will not be used if Cw = 0
      elseif (Cw .lt. 0) then
         ! Cw is negative, this is a fatal error.

               write(string,'(x,3a,i3,a,G12.6)')
     :               ' Solution '
     :               ,p%solute_names(solnum)
     :               (:lastnb(p%solute_names(solnum)))
     :               ,'(',node,') = ',Cw
            call fatal_error (err_internal,
     :           '-ve value has been passed to Freundlich solution'
     :            //new_line//string)
            Ctot = 0
            dCtot = 0

      else
         !Cw is positive, proceed with the calculations

         if ((Doubles_are_equal(p%fip(solnum,node),1d0))
     :         .or. (Doubles_are_equal(p%ex(solnum,node),0d0))) then
            ! Linear isotherm or no adsorption
            
            Ctot = Cw*(g%th(node) + p%ex(solnum,node))
            dCtot = g%th(node) + p%ex(solnum,node)

         else
            !nonlinear isotherm

            Ctot = g%th(node) * Cw
     :           + p%ex(solnum,node) * Cw ** p%fip(solnum,node)
            dCtot = g%th(node)
     :            + p%ex(solnum,node)
     :            *p%fip(solnum,node)
     :            *Cw**(p%fip(solnum,node)-1d0)
         endif
      endif

!````````````````````````````````````````````````````````````````````````````````
      ! Check for very small values, set to zero to avoid underflow with reals

      if (abs(Ctot) .lt. 1d-100) then
         Ctot = 0d0
      endif

      if (abs(dCtot) .lt. 1d-100) then
         dCtot = 0d0
      end if
!````````````````
      return
      end subroutine



* ====================================================================
       double precision function apswim_solve_freundlich
     :                                      (node, solnum, Ctot)
* ====================================================================

      implicit none

*+  Sub-Program Arguments
      integer node
      integer solnum
      double precision Ctot

*+  Purpose
*   Calculate the solute in solution for a given total solute
*   concentration for a given node.
*+  Changes
*   RCichota - 30/Jan/2010 - update name of proc., organize the newton solution
*                 added tests for -ve and very small values

*+  Constant Values
      integer max_iterations
      parameter (max_iterations = 1000)
*
      double precision tolerance
      parameter (tolerance = 1d-10)

*+  Local Variables
      double precision Cw
      double precision error_amount
      integer          iteration
      double precision f
      double precision dfdCw
      logical          solved
      character        message*200
      character        string*100

*- Implementation Section ----------------------------------

cRC    Changes by RCichota, 30/Jan/2010, updated in 10/Jul/2010
      ! Organize solution and add test for no adsorption or linear adsorption

      if (abs(Ctot).lt.1d-100) then
         ! really small value or zero, solution is zero

         solved = .true.
         Cw = 0

      elseif (Ctot.lt.0d0) then
         ! negative value for Ctot, this should have been catched already

         write(string,'(x,3a,i3,a,G12.6)')
     :         ' Total'
     :         ,p%solute_names(solnum)
     :         (:lastnb(p%solute_names(solnum)))
     :         ,'(',node,') = ',Ctot
         call fatal_error (err_internal,
     :         '-ve concentration was passed to Freundlich solution'
     :         //new_line//string)

         solved = .false.
         Cw = 0

      else
         ! Ctot is OK, proceed to calculations

         ! Check for no adsorption and whether the isotherm is linear
         if (Doubles_are_equal(p%ex(solnum,node),0d0)) then
            !There is no adsorption:

            Cw = ddivide (Ctot, g%th(node),0d0)
            solved = .true.

         elseif (Doubles_are_equal(p%fip(solnum,node),0d0)) then
            !Full adsorption, solute is immobile:

            Cw = 0d0
            solved = .true.

         elseif (Doubles_are_equal(p%fip(solnum,node),1d0)) then
            !Linear adsorption:

            Cw = ddivide (Ctot, g%th(node) + p%ex(solnum,node),0d0)
            solved = .true.

         else
            !Non linear isotherm:

            ! take initial guess for Cw
            Cw = (ddivide (Ctot, (g%th(node)+p%ex(solnum,node))
     :            , 0.d0))**(1.0/p%fip(solnum,node))
            if (Cw .lt. 0d0) then            ! test added by RCichota 09/Jul/2010
               write(string,*)
     :             '  '
     :             ,p%solute_names(solnum)
     :             (:lastnb(p%solute_names(solnum)))
     :             ,'(',node,') = ',Cw
     :             ,' - Iteration: 0'
               call fatal_error(err_internal,
     :             '-ve value for Cw on solving Freundlich1'
     :             //new_line//string)
            endif

            ! calculate value of isotherm function and the derivative.

            call apswim_freundlich (node,solnum,Cw,f,dfdCw)
            error_amount = f - Ctot

            if (abs(error_amount) .lt. tolerance) then
               ! It is already solved

               solved = .true.

            elseif (abs(dfdCw) .lt. 1d-100) then
               ! We are at zero (approximately) so Cw must be zero - this is a solution too

               Cw = 0d0
               solved = .true.

!            elseif (dfdCw) .gt. 1d100) then
!               ! derivative is too large, so Cw must be zero - this is a solution too

!               Cw = 0d0
!               solved = .true.

            else
               ! Iterate until a solution is found or max_iterations is reached

               solved = .false.
               do 100 iteration = 1,max_iterations

                  ! next value for Cw
                  Cw = Cw - ddivide(error_amount,2*dfdCw,0d0)
                  if (Cw .lt. 0d0) then            ! test added by RCichota 09/Jul/2010
                     write(string,*)
     :                  '  '
     :                  ,p%solute_names(solnum)
     :                  (:lastnb(p%solute_names(solnum)))
     :                  ,'(',node,') = ',Cw
     :                  ,' - Iteration: ',iteration
                     call fatal_error(err_internal,
     :                  '-ve value for Cw on solving Freundlich2'
     :                   //new_line//string)
                  endif

                  ! calculate new value of isotherm function and derivative.
                  call apswim_freundlich (node,solnum,Cw,f,dfdCw)
                  error_amount = f - Ctot

                  if (abs(error_amount) .lt. tolerance) then
                     solved = .true.
                     goto 200
                  endif

  100          continue
  200          continue
            endif
         endif
      endif

      if (solved) then

!````````````````````````````````````````````````````````````````````````````````
         ! Note: Sometimes small numerical errors can leave -ve concentrations.
         ! This will evaluate the error and define the appropriate response:
cRC      Changes by RCichota, 30/Jan/2010

         if (abs(Cw) .lt. 1d-100) then
            ! Value is REALLY small or zero and can be diregarded,
            !  set value to zero to avoid underflow with reals

            Cw = 0

         elseif (Cw .lt. 0) then
            ! Cw is negative, this is a fatal error.
            write(string,'(x,3a,i3,a,G12.6)')
     :            '  Solution '
     :            ,p%solute_names(solnum)
     :            (:lastnb(p%solute_names(solnum)))
     :            ,'(',node,') = ',Cw
            call fatal_error(err_internal,
     :            '-ve value for solute found in adsorption isotherm'
     :            //new_line//string)

            Cw = 0d0

         else
            ! Cw is positive and considerable

         endif
!````````````````````````````````````````````````````````````````````````````````

         ! Publish the computed value
         apswim_solve_freundlich = Cw

      else
         ! A solution was not found
         
         call fatal_error (err_internal,
     :           'APSwim failed to solve the freundlich isotherm')
         apswim_solve_freundlich = ddivide (Ctot, g%th(node), 0.d0)

      endif

      return
      end function



* ====================================================================
       subroutine apswim_get_obs_evap_variables ()
* ====================================================================

      implicit none

*+  Purpose
*      Get the evap values from other modules

*+  Local Variables
      integer numvals                  ! number of values returned
      double precision amount          ! amount of evaporation (mm)
      character time*6                 ! time of evaporation (hh:mm)
      double precision duration        ! duration of evaporation (min)
      integer time_of_day              ! time of g%day (min)
      double precision time_mins       ! time of evaporation (min)
      integer owner_module             ! id of module providing info.
      integer this_module              ! id of this module

*- Implementation Section ----------------------------------

      call get_double_var (
     :           unknown_module,
     :           p%evap_source,
     :           '(mm)',
     :           amount,
     :           numvals,
     :           0.d0,
     :           1000.d0)

      ! Check that apswim is not getting Eo from itself.
      ! Not really necessary if trap in send_my_variable routine
      ! is working correctly.

      owner_module = get_posting_module ()
      this_module = get_componentID ()
      if (owner_module.eq.this_module) then
         call fatal_error (ERR_User,
     :      'No module provided Eo value for APSwim')
         amount = 0.d0
      else
      endif

      call get_char_var_optional (
     :           unknown_module,
     :           'eo_time',
     :           '(hh:mm)',
     :           time,
     :           numvals)

      if (numvals.eq.0) then
         time = c%default_evap_time
         duration = c%default_evap_duration
      else

         call get_double_var (
     :           unknown_module,
     :           'eo_durn',
     :           '(min)',
     :           duration,
     :           numvals,
     :           0.d0,
     :           1440.d0*30.d0)    ! one month of mins
      endif

      time_of_day = apswim_time_to_mins (time)
      Time_mins = apswim_time (g%year,g%day,time_of_day)
      call apswim_insert_loginfo (
     :                             time_mins
     :                            ,duration
     :                            ,amount
     :                            ,g%SWIMEvapTime
     :                            ,g%SWIMEvapAmt
     :                            ,g%SWIMEvapNumPairs
     :                            ,SWIMLogSize)


      return
      end subroutine

* ====================================================================
       double precision function apswim_solute_amount (solnum,node)
* ====================================================================

      implicit none

*+  Sub-Program Arguments
      integer solnum
      integer node
*+  Changes
*   RCichota - 30-01-2010 - Added test for -ve value

*+  Local Variables
      double precision Ctot
      double precision dCtot
      character string*100
	  
*- Implementation Section ----------------------------------

*     ! Step One - calculate total solute in node from solute in
*      ! water and Freundlich isotherm.

      if (g%csl(solnum,node).lt.0d0) then
         write(string,*)
     :         ' solution'
     :         ,p%solute_names(solnum)
     :         (:lastnb(p%solute_names(solnum)))
     :         ,'(',node,') = ',g%csl(solnum,node)
         call fatal_error (err_internal,
     :         '-ve concentration in apswim_solute_amount'
     :         //new_line//string)
      endif

      call apswim_freundlich (node,solnum,g%csl(solnum,node)
     :                    ,Ctot,dCtot)

!````````````````````````````````````````````````````````````````````````````````
cRC   Changes by RCichota, 30/Jan/2010
      ! Note:- Sometimes small numerical errors can leave
      ! -ve concentrations.  This will check Ctot and take appropriate action

      if (abs(apswim_solute_amount) .lt. 1d-100) then
         ! value REALLY small, set to zero to avoid underflow with reals

         apswim_solute_amount = 0

      elseif (apswim_solute_amount .lt. 0) then
         write(string,'(x,3a,i3,a,G12.6)')
     :          '  Total '
     :          ,p%solute_names(solnum)
     :          (:lastnb(p%solute_names(solnum)))
     :          ,'(',node,') = ',Ctot
         call fatal_error(err_internal,
     :          '-ve value for solute amount'
     :         //new_line//string)

         apswim_solute_amount = 0d0

      else
         ! Value is positive, proceed with calculations

      end if
!````````````````````````````````````````````````````````````````````````````````

      ! convert solute ug/cc soil to kg/ha for node
      !
      !  kg      ug        cc soil      kg
      !  -- = -------- p%x -------- p%x --
      !  ha   cc soil        ha         ug

      apswim_solute_amount = Ctot            ! ug/cc soil
     :               * (p%dx(node)*1d8)      ! cc soil/ha
     :               * 1d-9                  ! kg/ug

      return
      end function



* ====================================================================
       double precision function dbound (x,l,u)
* ====================================================================

      implicit none

*+  Sub-Program Arguments
      double precision x,l,u

*- Implementation Section ----------------------------------

      dbound = dlbound (dubound(x,u),l)

      return
      end function



* ====================================================================
       double precision function apswim_solute_conc (solnum,node,amount)
* ====================================================================


      implicit none

*+  Sub-Program Arguments
      integer         solnum
      integer          node
      double precision amount
*+  Changes
*   RCichota - 30/Jan-2010 - Add test for -ve values
*+  Local Variables
      double precision conc_soil
      double precision conc_water
      character        string*100
*- Implementation Section ----------------------------------
!````````````````````````````````````````````````````````````````````````````````
         ! Note: Sometimes small numerical errors can leave -ve concentrations.
         ! This will evaluate the error and define the appropriate response:
cRC      Changes by RCichota, 30/Jan/2010

      if (conc_soil .lt. -(c%negative_conc_fatal)) then
         write(string,'(x,3a,i3,a,G12.6)')
     :         '  Total '
     :         ,p%solute_names(solnum)
     :         (:lastnb(p%solute_names(solnum)))
     :         ,'(',node,') = ',conc_soil
         call fatal_error(err_internal,
     :         '-ve value for solute within SWIM calculations'
     :         //new_line//string)

         conc_soil = 0d0

      elseif (conc_soil .lt. -(c%negative_conc_warn)) then
         write(string,'(x,3a,i3,a,G12.6)')
     :         '  Total '
     :         ,p%solute_names(solnum)
     :         (:lastnb(p%solute_names(solnum)))
     :         ,'(',node,') = ',conc_soil
     :         ,'- Value will be set to zero'
         call warning_error(err_internal,
     :         '-ve value for solute within SWIM calculations'
     :         //new_line//string)

         conc_soil = 0d0

      elseif (conc_soil .lt. 1d-100) then
         ! Value is REALLY small, no need to tell user,
         ! set value to zero to avoid underflow with reals

         conc_soil = 0d0

      else
         ! Value is positive and considerable

      endif
!````````````````````````````````````````````````````````````````````````````````

         ! convert solute from kg/ha to ug/cc soil
         ! ug Sol    kg Sol    ug   ha(node)
         ! ------- = ------- * -- * -------
         ! cc soil   ha(node)  kg   cc soil

      conc_soil = amount               ! kg/ha
     :            * 1d9                ! ug/kg
     :            / (p%dx(node)*1d8)   ! cc soil/ha

      conc_water = apswim_solve_freundlich
     :                                    (node
     :                                    ,solnum
     :                                    ,conc_soil)

      apswim_solute_conc = conc_water
      return
      end function


* ====================================================================
       double precision function apswim_slupf (crop, solnum)
* ====================================================================

      implicit none

*+  Sub-Program Arguments
      integer crop
      integer solnum

*+  Local Variables

*- Implementation Section ----------------------------------

      apswim_slupf = 0d0

      return
      end function



* ====================================================================
       subroutine apswim_check_demand ()
* ====================================================================

      implicit none

*+  Local Variables
      double precision tpsuptake, demand
      integer layer, crop, solnum
      integer num_active_crops

*- Implementation Section ----------------------------------

      do 600 crop = 1, g%num_crops
      do 500 solnum = 1,p%num_solutes

         tpsuptake = 0d0
         do 400 layer = 0,p%n
            tpsuptake = tpsuptake
     :                + max(g%psuptake(solnum,crop,layer), 0d0)
  400    continue

         demand =
     :             max(g%solute_demand (crop,solnum)
     :                    - tpsuptake
     :                ,0d0)

         if (demand.le.0.0) then
               g%demand_is_met(crop, solnum) = .true.
         else
               g%demand_is_met(crop, solnum) = .false.
         endif

  500 continue
  600 continue

      return
      end subroutine



* ====================================================================
       subroutine apswim_report_status ()
* ====================================================================

      implicit none

*+  Purpose
*   Dump a series of values to output file to be used by users in
*   determining convergence problems, etc.

*+  Local Variables
       integer i
       double precision d1,d2,d3 ! dummy variables
       double precision t_psi(0:M)
       double precision t_th(0:M)
       character        string*500

*- Implementation Section ----------------------------------

      do 100 i=0,p%n
         call apswim_trans(g%p(i),t_psi(i),d1,d2)
         call apswim_interp (i,t_psi(i),t_th(i),d1,d2,d3)
  100 continue

      call write_string(new_line)
      call write_string('================================')
      call write_string('     Error Report Status')
      call write_string('================================')
      write(string,*) 'time =',g%day,g%year,mod(g%t-g%dt,24d0)
      call write_string(trim(string))
      write(string,*) 'dt=',g%dt*2.0
      call write_string(trim(string))
      write(string,*) 'psi= ',(t_psi(i),i=0,p%n)
      call write_string(trim(string))
      write(string,*) 'th= ',(t_th(i),i=0,p%n)
      call write_string(trim(string))
      write(string,*) 'h =',g%h
      call write_string(trim(string))
      write(string,*) 'ron =',g%ron
      call write_string(trim(string))
      call write_string('================================')

      return
      end subroutine

* ====================================================================
       subroutine apswim_insert_loginfo (time
     :                                  ,duration
     :                                  ,amount
     :                                  ,SWIMtime
     :                                  ,SWIMamt
     :                                  ,SWIMNumPairs
     :                                  ,SWIMArraySize)
* ====================================================================

      implicit none

*+  Sub-Program Arguments
       double precision amount          ! (mm)
       double precision duration        ! (min)
       double precision time            ! (min since start)
       integer          SWIMArraySize
       double precision SWIMtime(SWIMArraySize)
       double precision SWIMAmt(SWIMArraySize)
       integer          SWIMNumPairs

*+  Local Variables
      double precision AvInt
      integer          counter
      integer          counter2
      double precision Extra
      double precision fAmt
      double precision ftime
      double precision SAmt

*- Implementation Section ----------------------------------

      ftime = time+duration/60d0
      counter2 = 0

      if (SWIMNumPairs.gt.SWIMArraySize-2) then
         call fatal_error (Err_Internal,
     :   'No memory left for log data data')

      else if (ftime .lt. SWIMTime(1)) then
         ! do nothing - it is not important

      else if (time.lt.SWIMTime(1)) then
         ! for now I shall say that this shouldn't happen
         call fatal_error (Err_User,
     :         'log time before start of run')

       else

         counter2 = 0
         SAmt = dlinint(time,SWIMTime,SWIMAmt,SWIMNumPairs)
         FAmt = dlinint(Ftime,SWIMTime,SWIMAmt,SWIMNumPairs)


         ! Insert starting element placeholder into log
         do 10 counter = 1, SWIMNumPairs
            if (Doubles_are_equal(SWIMTime(counter),time)) then
               ! There is already a placeholder there
               goto 11
            else if (SWIMTime(counter).gt.time) then
               SWIMNumPairs = SWIMNumPairs + 1
               do 5 counter2 = SWIMNumPairs,counter+1,-1
                  SWIMTime(counter2) = SWIMTime(counter2-1)
                  SWIMAmt(counter2) = SWIMAmt(counter2-1)
    5          continue
               SWIMTime(counter) = Time
               SWIMAmt(counter) = Samt
               goto 11
            else
            endif
   10    continue
         ! Time > last log entry
         SWIMNumPairs = SWIMNumPairs + 1
         SWIMTime(SWIMNumPairs) = Time
         SWIMAmt(SWIMNumPairs) = Samt

   11    continue

         ! Insert ending element placeholder into log
         do 13 counter = 1, SWIMNumPairs
            if (Doubles_are_equal(SWIMTime(counter),ftime)) then
               ! There is already a placeholder there
               goto 14
            else if (SWIMTime(counter).gt.ftime) then
               SWIMNumPairs = SWIMNumPairs + 1
               do 12 counter2 = SWIMNumPairs,counter+1,-1
                  SWIMTime(counter2) = SWIMTime(counter2-1)
                  SWIMAmt(counter2) = SWIMAmt(counter2-1)
   12          continue
               SWIMTime(counter) = FTime
               SWIMAmt(counter) = Famt
               goto 14
            else
            endif
   13    continue
         ! Time > last log entry
         SWIMNumPairs = SWIMNumPairs + 1
         SWIMTime(SWIMNumPairs) = FTime
         SWIMAmt(SWIMNumPairs) = Famt

   14    continue

         ! Now add extra quantity to each log entry are required

         AvInt = amount/(duration/60d0)

         do 100 counter = 1, SWIMNumPairs

            if (Counter.eq.1) then
               Extra = 0d0

            elseif (SWIMTime(Counter).gt.time) then

               extra = AvInt *
     :            min(SWIMTime(Counter)-time,(Duration/60d0))

            else
               Extra = 0d0
            endif

            SWIMAmt(Counter) = SWIMAmt(Counter) + extra

  100    continue

      endif

      return
      end subroutine

* ====================================================================
      subroutine apswim_purge_log_info (time
     :                                 ,SWIMTime
     :                                 ,SWIMAmt
     :                                 ,SWIMNumPairs)
* ====================================================================

      implicit none

*+  Sub-Program Arguments
       double precision time
       double precision SWIMTime(*)
       double precision SWIMAmt (*)
       integer          SWIMNumPairs

*+  Local Variables
      integer counter
      integer new_index
      integer new_start
      integer old_numpairs

*- Implementation Section ----------------------------------

      old_numpairs = SWIMNumPairs
      new_start = 1

      do 100 counter = SwimNumPairs,1,-1
         if (SwimTime(counter).le.time) then
            ! we have found the oldest record we need to keep
            new_start = counter
            goto 101
         else
         endif
 100  continue
 101  continue

      new_index = 0
      do 200 counter = new_start,SwimNumPairs
         new_index = new_index + 1
         SwimTime  (new_index) = SwimTime(counter)
         SwimAmt   (new_index) = SwimAmt (counter)
 200  continue
      SwimNumPairs = new_index

      do 300 counter = SwimNumPairs+1, old_numpairs
         SwimTime  (counter) = 0.0d0
         SwimAmt   (counter) = 0.0d0
 300  continue

      return
      end subroutine



* ====================================================================
       subroutine apswim_conc_water_solute (solname,conc_water_solute)
* ====================================================================

      implicit none

*+  Sub-Program Arguments
      character solname*(*)
      double precision conc_water_solute(0:p%n)
*+  Changes
*     30-01-2010 - RCichota - added test for -ve values, causes a fatal error if so


*+  Purpose
*      Calculate the concentration of solute in water (ug/l).  Note that
*      this routine is used to calculate output variables and input
*      variablesand so can be called at any time during the simulation.
*      It therefore must use a solute profile obtained from the solute's
*      owner module.  It therefore also follows that this routine cannot
*      be used for internal calculations of solute concentration during
*      the process stage etc.

*+  Local Variables
      integer          node
      double precision solute_n(0:M) ! solute at each node
      integer          solnum
      integer          numvals
      character        string*100 

*+  Initial Data Values
      call fill_double_array(conc_water_solute(0),0d0,p%n+1)

*- Implementation Section ----------------------------------

      solnum = apswim_solute_number (solname)

      if (solnum .gt. 0) then
         ! only continue if solute exists.
         if (g%solute_owners(solnum).ne.0) then

            call get_double_array (
     :              g%solute_owners(solnum),
     :               solname,
     :              p%n+1,
     :              '(kg/ha)',
     :              solute_n(0),
     :              numvals,
     :              c%lb_solute,
     :              c%ub_solute)



         else
               call fatal_error (Err_User,
     :            'No module has registered ownership for solute: '
     :            //solname)

         endif

         if (numvals.gt.0) then

            do 50 node=0, p%n
!````````````````````````````````````````````````````````````````````````````````
cRC            Changes by RCichota, 30/Jan/2010
               ! Note: Sometimes small numerical errors can leave -ve concentrations.
               ! This will check for -ve or very small values being passed by other modules
               !  and define the appropriate response:

               if (solute_n(node) .lt. -(c%negative_conc_fatal)) then
                  write(string,'(x,3a,i3,a,G12.6)')
     :                  '  Total '
     :                  ,p%solute_names(solnum)
     :                  (:lastnb(p%solute_names(solnum)))
     :                  ,'(',node,') = ',solute_n(node)
                  call fatal_error(err_internal,
     :                  '-ve value for solute was passed to SWIM'
     :                  //new_line//string)
               
                  solute_n(node) = 0d0
               
               elseif (solute_n(node) .lt. -(c%negative_conc_warn)) then
                  write(string,'(x,3a,i3,a,G12.6)')
     :                  '  Total '
     :                  ,p%solute_names(solnum)
     :                  (:lastnb(p%solute_names(solnum)))
     :                  ,'(',node,') = ',solute_n(node)
     :                  ,'- Value will be set to zero'
                  call warning_error(err_internal,
     :                  '-ve value for solute was passed to SWIM'
     :                  //new_line//string)
               
                  solute_n(node) = 0d0
               
               elseif (solute_n(node) .lt. 1d-100) then
                  ! Value is REALLY small, no need to tell user,
                  ! set value to zero to avoid underflow with reals
               
                  solute_n(node) = 0d0
               
               else
                  ! Value is positive and considerable
               
               endif
!````````````````````````````````````````````````````````````````````````````````
			
               ! convert solute from kg/ha to ug/cc soil
               ! ug Sol    kg Sol    ug   ha(node)
               ! ------- = ------- * -- * -------
               ! cc soil   ha(node)  kg   cc soil

               g%cslstart(solnum,node) = solute_n(node)
               solute_n(node) = solute_n(node)
     :                        * 1d9             ! ug/kg
     :                        / (p%dx(node)*1d8) ! cc soil/ha

               conc_water_solute(node) = apswim_solve_freundlich
     :                                             (node
     :                                             ,solnum
     :                                             ,solute_n(node))

   50       continue

         else
            call fatal_error (Err_User,
     :         'You have asked apswim to use a '
     :         //' solute that is not in the system :-'
     :         //solname)
         endif

      else
               call fatal_error (Err_User,
     :            'You have asked apswim to use a'
     :            //' solute that it does not know about :-'
     :            //solname)
      endif

      return
      end subroutine



* ====================================================================
       subroutine apswim_conc_adsorb_solute (solname,conc_adsorb_solute)
* ====================================================================

      implicit none

*+  Sub-Program Arguments
      character solname*(*)
      double precision conc_adsorb_solute(0:p%n)

*+  Purpose
*      Calculate the concentration of solute adsorbed (ug/g soil). Note that
*      this routine is used to calculate output variables and input
*      variablesand so can be called at any time during the simulation.
*      It therefore must use a solute profile obtained from the solute's
*      owner module.  It therefore also follows that this routine cannot
*      be used for internal calculations of solute concentration during
*      the process stage etc.
*+  Changes
*     30-01-2010 - RCichota - added test for -ve values, causes a fatal error if so

*+  Local Variables
      integer          node
      double precision solute_n(0:M) ! solute at each node
      integer          solnum
      integer          numvals
      double precision conc_water_solute ! (ug/g water)
      character string*100
*+  Initial Data Values
      call fill_double_array(conc_adsorb_solute(0),0d0,p%n+1)

*- Implementation Section ----------------------------------

       solnum = apswim_solute_number (solname)

      if (solnum .gt. 0) then
         ! only continue if solute exists.
         call get_double_array (
     :           unknown_module,
     :           solname,
     :           p%n+1,
     :           '(kg/ha)',
     :           solute_n(0),
     :           numvals,
     :           c%lb_solute,
     :           c%ub_solute) 

         if (numvals.gt.0) then

            do 50 node=0, p%n

!````````````````````````````````````````````````````````````````````````````````
cRC            Changes by RCichota, 30/Jan/2010
               ! Note: Sometimes small numerical errors can leave -ve concentrations.
               ! This will check for -ve or very small values being passed by other modules
               !  and define the appropriate response:

               if (solute_n(node) .lt. -(c%negative_conc_fatal)) then
                  write(string,'(x,3a,i3,a,G12.6)')
     :                  '  Total '
     :                  ,p%solute_names(solnum)
     :                  (:lastnb(p%solute_names(solnum)))
     :                  ,'(',node,') = ',solute_n(node)
                  call fatal_error(err_internal,
     :                  '-ve value for solute was passed to SWIM'
     :                  //new_line//string)

                  solute_n(node) = 0d0

               elseif (solute_n(node) .lt. -(c%negative_conc_warn)) then
                  write(string,'(x,3a,i3,a,G12.6)')
     :                  '  Total '
     :                  ,p%solute_names(solnum)
     :                  (:lastnb(p%solute_names(solnum)))
     :                  ,'(',node,') = ',solute_n(node)
     :                  ,'- Value will be set to zero'
                  call warning_error(err_internal,
     :                  '-ve value for solute was passed to SWIM'
     :                  //new_line//string)

                  solute_n(node) = 0d0

               elseif (solute_n(node) .lt. 1d-100) then
                  ! Value is REALLY small, no need to tell user,
                  ! set value to zero to avoid underflow with reals

                  solute_n(node) = 0d0

               else
                  ! Value is positive and considerable

               endif
!````````````````````````````````````````````````````````````````````````````````

               ! convert solute from kg/ha to ug/cc soil
               ! ug Sol    kg Sol    ug   ha(node)
               ! ------- = ------- * -- * -------
               ! cc soil   ha(node)  kg   cc soil

               solute_n(node) = solute_n(node)  ! kg/ha
     :                     * 1d9                ! ug/kg
     :                     / (p%dx(node)*1d8)   ! cc soil/ha

               conc_water_solute = apswim_solve_freundlich
     :                                          (node
     :                                          ,solnum
     :                                          ,solute_n(node))

 !                  conc_adsorb_solute(node) =
 !     :              ddivide(solute_n(node)
 !     :                         - conc_water_solute * g%th(node)
 !     :                      ,p%rhob(node)
 !     :                      ,0d0)

               conc_adsorb_solute(node) =
     :                   p%ex(solnum,node)
     :                  * conc_water_solute ** p%fip(solnum,node)

   50       continue

         else
               call fatal_error (Err_User,
     :            'You have asked apswim to use a '
     :            //' solute that is not in the system :-'
     :            //solname)
         endif

      else
               call fatal_error (Err_User,
     :            'You have asked apswim to use a'
     :            //' solute that it does not know about :-'
     :            //solname)
      endif

      return
      end subroutine



* ====================================================================
      subroutine apswim_get_flow (flow_name, flow_array, flow_units
     :                           ,flow_flag)
* ====================================================================

      implicit none

*+  Sub-Program Arguments
      double precision flow_array(0:p%n+1)
      character        flow_name *(*)
      character        flow_units*(*)
      logical          flow_flag

*+  Local Variables
      integer node
      integer solnum

*+  Initial Data Values
      ! set to false to start - if match is found it is
      ! set to true.
      flow_flag = .false.
*
      flow_units = ' '

*- Implementation Section ----------------------------------

      call fill_double_array (flow_array(0), 0d0, p%n+2)

      if (flow_name.eq.'water') then
          flow_flag = .true.
          flow_units = '(mm)'
          do 40 node=0,p%n+1
             flow_array(node) = g%TD_wflow(node)
   40     continue

      else
         do 100 solnum = 1, p%num_solutes
            if (p%solute_names(solnum).eq.flow_name) then
               do 50 node=0,p%n+1
                  flow_array(node) = g%TD_sflow(solnum,node)
   50          continue
               flow_flag = .true.
               flow_units = '(kg/ha)'
               goto 110
            else
            endif
  100    continue
  110    continue
      endif

      return
      end subroutine



* ====================================================================
       subroutine apswim_diagnostics (pold)
* ====================================================================

      implicit none

*+  Sub-Program Arguments
      double precision pold(0:p%n)

*+  Local Variables
       character string*100
       integer   layer
       integer   nlayers
       double precision dummy1, dummy2, dummy3, dummy4, dummy5, dummy6
       double precision k

*- Implementation Section ----------------------------------

      if (p%diagnostics) then

      string =     '     APSwim Numerical Diagnostics'
      call write_string (string)

      string =     '     --------------------------------------------'
     :            //    '----------------------------------'
      call write_string (string)

      string =     '      depth      Theta         psi    '
     :            //    '    K           p          p*'
      call write_string (string)

      string =     '     --------------------------------------------'
     :            //    '----------------------------------'
      call write_string (string)

      nlayers = count_of_double_vals (p%x,M)

      do 200 layer = 0,nlayers-1
         call apswim_watvar(layer,g%p(layer),dummy1,dummy2,dummy3,dummy4
     :                     ,dummy5,k,dummy6)
         write(string
     :  ,'(5x,f6.1,9x,f9.7,4(1x,f10.3))')
     :       p%x(layer)*10., g%th(layer)
     :       ,g%psi(layer), k ,g%p(layer), pold(layer)
         call write_string (string)
  200 continue

      string =     '     --------------------------------------------'
     :            //    '----------------------------------'
      call write_string (string)


      endif
      
      return
      end subroutine

* ====================================================================
       subroutine apswim_get_residue_variables ()
* ====================================================================

      implicit none

*+   Purpose
*      Get the values of residue variables from other modules

*+  Local Variables
      integer numvals                  ! number of values returned

*- Implementation Section ----------------------------------

         call get_double_var_optional (
     :            unknown_module,
     :           'surfaceom_cover',
     :           '(0-1)',
     :           g%residue_cover,
     :           numvals,
     :           0d0,
     :           1d0)

         if (numvals.le.0) then
            g%residue_cover = 0.0
         else
         endif

      return
      end subroutine

* ====================================================================
      double precision function apswim_cover_eos_redn  ()
* ====================================================================

      implicit none

*+  Purpose
*      Calculate reduction in potential soil evaporation
*      due to residues on the soil surface.
*      Approach taken from directly from Soilwat code.

*+  Local Variables
      double precision eos_canopy_fract  ! fraction of potential soil evaporation
                                         ! limited by crop canopy (mm)
      double precision eos_residue_fract ! fraction of potential soil evaporation
                                         ! limited by crop residue (mm)

*- Implementation Section ----------------------------------

         !---------------------------------------+
         ! reduce Eo to that under plant CANOPY                    <DMS June 95>
         !---------------------------------------+

         !  Based on Adams, Arkin & Ritchie (1976) Soil Sci. Soc. Am. J. 40:436-
         !  Reduction in potential soil evaporation under a canopy is determined
         !  the "% shade" (ie cover) of the crop canopy - this should include g%th
         !  green & dead canopy ie. the total canopy cover (but NOT near/on-grou
         !  residues).  From fig. 5 & eqn 2.                       <dms June 95>
         !  Default value for c%canopy_eos_coef = 1.7
         !              ...minimum reduction (at cover =0.0) is 1.0
         !              ...maximum reduction (at cover =1.0) is 0.183.

      eos_canopy_fract = exp (-c%canopy_eos_coef * g%crop_cover)

         !-----------------------------------------------+
         ! reduce Eo under canopy to that under mulch            <DMS June 95>
         !-----------------------------------------------+

         !1a. adjust potential soil evaporation to account for
         !    the effects of surface residue (Adams et al, 1975)
         !    as used in Perfect
         ! BUT taking into account that residue can be a mix of
         ! residues from various crop types <dms june 95>

         !    [DM. Silburn unpublished data, June 95 ]
         !    <temporary value - will reproduce Adams et al 75 effect>
         !     c%A_to_evap_fact = 0.00022 / 0.0005 = 0.44

         eos_residue_fract = (1. - g%residue_cover)**c%a_to_evap_fact


      apswim_cover_eos_redn  = eos_canopy_fract * eos_residue_fract

      return
      end function


*     ===========================================================
      subroutine apswim_on_new_solute (variant, fromID)
*     ===========================================================

      implicit none

*+  Purpose
*     Find the owner of any run_solutes

*+  Local Variables
      integer, intent(in) :: variant
      integer, intent(in) :: fromID
      type(newSoluteType) :: newsolute
      integer numvals
      integer node
      character names(nsol)*32
      integer sender
      integer counter
      integer solnum
      double precision temp(0:M)

*- Implementation Section ----------------------------------

      call unpack_newsolute(variant, newsolute)
	  
      sender = fromID
      numvals = newsolute%num_solutes
      names(1:numvals) = newsolute%solutes(1:numvals)
	  
      do 100 counter = 1, numvals

         if ((names(counter).eq.'no3').or.(names(counter).eq.'nh4').or.
     :       (names(counter).eq.'urea').or.
     :       (names(counter).eq.'cl').or.
     :       (names(counter).eq.'nitrificationinhibitor').or.
     :       (names(counter).eq.'denitrificationinhibitor').or.
     :       (names(counter).eq.'mineralisationinhibitor').or.
     :       (names(counter).eq.'ureaseinhibitor').or.     
     :       (names(counter).eq.'tracer')) then
            p%num_solutes = p%num_solutes + 1
            p%solute_names(p%num_solutes) = names(counter)
            g%solute_owners(p%num_solutes) = sender

         call Read_double_var (
     :              'constants',
     :              Trim(names(counter))//'slos',
     :              '()',
     :              c%slos(p%num_solutes),
     :              numvals,
     :               0d0,
     :               1d4)
         call Read_double_var (
     :              'constants',
     :              Trim(names(counter))//'d0',
     :              '()',
     :              c%d0(p%num_solutes),
     :              numvals,
     :               0d0,
     :               1d4)
      

         temp(:)=0d0
         call Read_double_array(
     :           solute_section,
     :           Trim(names(counter))//'Exco',
     :           M+1,
     :           '()',
     :           temp,
     :           numvals,
     :           0d0,
     :           15000d0)
         p%exco(p%num_solutes,0:M)=temp(0:M)
         
         temp(:)=0d0
         call Read_double_array(
     :           solute_section,
     :           Trim(names(counter))//'FIP',
     :           M+1,
     :           '()',
     :           temp,
     :           numvals,
     :           0d0,
     :           15000d0)
         p%fip(p%num_solutes,0:M)=temp(0:M)


         call Read_double_var(
     :           solute_section,
     :           'WaterTable'//Trim(names(counter)),
     :           '(ppm)',
     :           p%cslgw(p%num_solutes),
     :           numvals,
     :           0d0,
     :           10d0)
     
           
               p%dcon(p%num_solutes) = c%d0(p%num_solutes)*p%a

         do 40 node = 0,p%n
            p%ex(p%num_solutes,node) = p%rhob(node)
     :         *p%exco(p%num_solutes,node)
   40    continue

           
         else
             ! not a run_solute
            call Write_string (
     :          'Note - APSwim will not redistribute '
     :           //names(counter))
         endif

  100 continue

      return
      end subroutine


*     ===========================================================
      subroutine apswim_ONtick (variant)
*     ===========================================================

      implicit none

      integer, intent(in) :: variant

*+  Purpose
*     Update internal time record and reset daily state variables.

*+  Local Variables
      integer intTimestep
      integer          counter
      integer          solnum
      double precision start_timestep
      double precision TEMPSolTime(SWIMLogSize)
      double precision TEMPSolAmt(SWIMLogSize)
      integer          TEMPSolNumPairs
      integer          time_mins
      type(timeType) :: tick


*- Implementation Section ----------------------------------

      call unpack_time(variant, tick)
      call jday_to_day_of_year(tick%startday, g%day, g%year)

      ! dph - need to setup g%apsim_time and g%apsim_timestep
      !call handler_ONtick(g%day, g%year, g%apsim_time ,intTimestep)
      !g%apsim_timestep = intTimestep

      ! NIH - assume daily time step for now until someone needs to
      !       do otherwise.
      g%apsim_time = '00:00'
      g%apsim_timestep = 1440d0

      ! Started new timestep so purge all old timecourse information
      ! ============================================================



      time_mins = apswim_time_to_mins (g%apsim_time)
      start_timestep = apswim_time (g%year,g%day,time_mins)

      call apswim_purge_log_info(start_timestep
     :                          ,g%SWIMRainTime
     :                          ,g%SWIMRainAmt
     :                          ,g%SWIMRainNumPairs)

      call apswim_purge_log_info(start_timestep
     :                          ,g%SWIMEvapTime
     :                          ,g%SWIMEvapAmt
     :                          ,g%SWIMEvapNumPairs)

      do 100 solnum = 1, p%num_solutes
        TEMPSolNumPairs = g%SWIMSolNumPairs(solnum)
        do 50 counter = 1, TEMPSolNumPairs
           TEMPSolTime(counter) = g%SWIMSolTime(solnum,counter)
           TEMPSolAmt(counter) = g%SWIMSolAmt(solnum,counter)
   50   continue

         call apswim_purge_log_info(start_timestep
     :                             ,TEMPSolTime
     :                             ,TEMPSolAmt
     :                             ,TEMPSolNumPairs)

        g%SWIMSolNumPairs(solnum) = TEMPSolNumPairs
        do 60 counter = 1, TEMPSolNumPairs
           g%SWIMSolTime(solnum,counter) = TEMPSolTime(counter)
           g%SWIMSolAmt(solnum,counter) = TEMPSolAmt(counter)
   60   continue
  100 continue

      g%SubSurfaceInFlow = 0.0

      return
      end subroutine

* ====================================================================
       subroutine apswim_remove_interception ()
* ====================================================================

      implicit none

*+   Purpose
*      Remove interception losses from rainfall record

*+  Local Variables
      integer numvals                  ! number of values returned

      double precision intercep
      double precision residueinterception
*- Implementation Section ----------------------------------

         call get_double_var_optional (
     :            unknown_module,
     :           'interception',
     :           '(mm)',
     :           intercep,
     :           numvals,
     :           0d0,
     :           1000d0)

         if (numvals.le.0) then
            intercep = 0d0
         else
         endif

         call get_double_var_optional (
     :            unknown_module,
     :           'residueinterception',
     :           '(mm)',
     :           residueinterception,
     :           numvals,
     :           0d0,
     :           1000d0)

         if (numvals.le.0) then
            residueinterception = 0d0
         else
         endif
         
      call apswim_remove_from_rainfall(intercep+residueinterception)

      return
      end subroutine

* ====================================================================
       subroutine apswim_remove_from_rainfall(amount)
* ====================================================================

      implicit none
      double precision amount
      integer start                ! record for start of interception      
      integer          time_mins
      double precision start_timestep
      integer counter
      double precision tot_rain
      double precision fraction

*- Implementation Section ----------------------------------
                  
      if (amount.gt.0d0) then

         ! Firstly, find the record for start of rainfall for the
         ! current day - ie assume interception cannot come from
         ! rainfall that started before the current day.

         time_mins = apswim_time_to_mins (g%apsim_time)
         start_timestep = apswim_time (g%year,g%day,time_mins)

         do 100 counter = 1, g%SwimRainNumPairs
            if (g%SwimRainTime(counter).ge.start_timestep) then
               ! we have found the first record for the current timestep
               start = counter
               goto 101
            else
            endif
 100     continue
 101     continue

         ! Assume that interception is taken over all rainfall
         ! information given thus far - can do nothing better than this

         tot_rain = g%SWIMRainAmt(g%SWIMRainNumPairs)
     :            - g%SWIMRainAmt(start)

         fraction = ddivide(amount,tot_rain,1d6)
         if (fraction.gt.1d0) then
            call fatal_error(ERR_Internal,'Interception > Rainfall')
         else
            do 200 counter = start+1, g%SWIMRainNumPairs
               g%SWIMRainAmt(counter) = g%SWIMRainAmt(start)
     :            + (g%SWIMRainAmt(counter)-g%SWIMRainAmt(start))
     :                 * (1d0 - fraction)
  200       continue
         endif

      else
         ! do not bother removing zero
      endif
      return
      end subroutine
       
* ====================================================================
       double precision function apswim_water_table ()
* ====================================================================

      implicit none

*+   Purpose
*      Calculate depth of water table from soil surface

*+  Local Variables
      integer i                    ! simple counter
      double precision water_table ! water table depth (mm)

*- Implementation Section ----------------------------------

      ! set default value to bottom of soil profile.
      
      water_table = p%x(p%n)*10d0
      
      loop: do i=0,p%n
         if (g%psi(i).gt.0) then
            water_table = (p%x(i)-g%psi(i))*10d0
            exit loop
         endif
      end do loop

      apswim_water_table = water_table

      return
      end function

*     ===========================================================
      subroutine apswim_New_Profile_Event ()
*     ===========================================================

      implicit none

*+  Purpose
*     Advise other modules of new profile specification

*+  Local Variables
      type(NewProfileType) :: newProfile

*- Implementation Section ----------------------------------

      newProfile%dlayer(:) = p%dlayer(0:p%n)
      newProfile%num_dlayer = p%n+1

      newProfile%air_dry_dep(:) = 0.0
      newProfile%num_air_dry_dep = p%n+1

      newProfile%ll15_dep(:) = p%ll15(0:p%n)*p%dlayer(0:p%n)
      newProfile%num_ll15_dep = p%n+1

      newProfile%dul_dep(:) = p%dul(0:p%n)*p%dlayer(0:p%n)
      newProfile%num_dul_dep = p%n+1

      newProfile%sat_dep(:) = p%sat(0:p%n)*p%dlayer(0:p%n)
      newProfile%num_sat_dep = p%n+1

      newProfile%sw_dep(:) = g%th(0:p%n)*p%dlayer(0:p%n)
      newProfile%num_sw_dep = p%n+1

      newProfile%bd(:) = p%rhob(0:p%n)
      newProfile%num_bd = p%n+1

      call publish_NewProfile(ID%new_profile, newProfile)

      return
      end subroutine

!     ===========================================================
      double precision function NextLogTime(logtime,numpairs)
!     ===========================================================

      implicit none

      double precision logtime(*)
      integer          numpairs

*+  Local Variables
      integer          counter
      logical          found
      double precision end_of_day

*- Implementation Section ----------------------------------

      found = .false.

      do 10 counter = 1, NumPairs
         if (logtime(counter).gt.g%t) then
            found = .true.
            NextLogTime = logtime(counter)
            goto 999
         else
            ! smaller or same - keep looking to next one
         endif
   10 continue
  999 continue

      if (.not. found) then
          end_of_day = apswim_time (g%year
     :                             ,g%day
     :                             ,apswim_time_to_mins(g%apsim_time)
     :                                +int(g%apsim_timestep))
         NextLogTime = end_of_day
      endif

      return
      end function

*     ===========================================================
      subroutine apswim_CN_runoff ()
*     ===========================================================

      implicit none
      double precision rain
       double precision start_of_day
       double precision end_of_day
             
      call apswim_cover_surface_runoff (g%cover_surface_runoff)

         start_of_day = apswim_time (g%year,g%day,
     :                               apswim_time_to_mins(g%apsim_time))
         end_of_day = apswim_time (g%year
     :                            ,g%day
     :                            ,apswim_time_to_mins(g%apsim_time)
     :                                +int(g%apsim_timestep))

      rain = (apswim_crain(end_of_day)-
     :                     apswim_crain(start_of_day))*10d0      
      call apswim_scs_runoff (rain,g%CN_runoff)
      
      call apswim_remove_from_rainfall (g%CN_runoff)
      g%TD_runoff = g%TD_runoff + g%CN_runoff      
      
      return
      end subroutine
      
*     ===========================================================
      subroutine apswim_cover_surface_runoff (cover_surface_runoff)
*     ===========================================================

      implicit none

*+  Sub-Program Arguments
      double precision cover_surface_runoff   ! (output) effective runoff cover (0-1)


*+  Local Variables
      double precision canopy_fact           ! canopy factor (0-1)
      integer    crop                        ! crop number
      double precision effective_crop_cover  ! effective crop cover (0-1)
      double precision cover_surface_crop    ! efective total cover (0-1)
 
*- Implementation Section ----------------------------------

          ! cover cn response from perfect   - ML  & dms 7-7-95
          ! nb. perfect assumed crop canopy was 1/2 effect of mulch
          ! This allows the taller canopies to have less effect on runoff
          ! and the cover close to ground to have full effect (jngh)

          ! weight effectiveness of crop canopies
          !    0 (no effect) to 1 (full effect)

      cover_surface_crop = 0d0
      do 1000 crop = 1, g%num_crops
         if (g%canopy_height(crop).ge.0d0) then
            canopy_fact = dlinint (g%canopy_height(crop)
     :                             , c%canopy_fact_height
     :                             , c%canopy_fact
     :                             , c%num_canopy_fact)
         else
            canopy_fact = c%canopy_fact_default
         endif

         effective_crop_cover = g%cover_tot(crop) * canopy_fact
         cover_surface_crop = dadd_cover (cover_surface_crop
     :                                   , effective_crop_cover)
1000  continue
          ! add cover known to affect runoff
          !    ie residue with canopy shading residue

      cover_surface_runoff = dadd_cover (cover_surface_crop
     :                         ,  g%residue_cover)

      return
      end subroutine

      double precision function dadd_cover (cover1, cover2)
   !     ===========================================================
      implicit none

   !+ Sub-Program Arguments
      double precision cover1                ! (INPUT) first cover to combine (0-1)
      double precision cover2                ! (INPUT) second cover to combine (0-1)

   !+ Purpose
   !     Combines two covers

   !+  Definition
   !     "cover1" and "cover2" are numbers between 0 and 1 which
   !     indicate what fraction of sunlight is intercepted by the
   !     foliage of plants.  This function returns a number between
   !     0 and 1 indicating the fraction of sunlight intercepted
   !     when "cover1" is combined with "cover2", i.e. both sets of
   !     plants are present.

   !+  Mission Statement
   !     cover as a result of %1 and %2

   !+ Changes
   !       130896 jngh specified and programmed

   !+ Calls

   !+ Local Variables
      double precision bare                  ! bare proportion (0-1)

   !- Implementation Section ----------------------------------

      bare = (1d0 - cover1)*(1d0 - cover2)
      dadd_cover = 1d0 - bare

      return
      end function

*     ===========================================================
      subroutine apswim_scs_runoff (rain,runoff)
*     ===========================================================

      implicit none

*+  Sub-Program Arguments
      double precision       rain                  ! (input) rainfall for day (mm)
      double precision       runoff                ! (output) runoff for day (mm)

*+  Purpose
*        calculate runoff using scs curve number method


*+  Local Variables
      double precision cn              ! scs curve number
      double precision cn1             ! curve no. for dry soil (antecedant)
                                       !    moisture
      double precision cn3             ! curve no. for wet soil (antecedant)
                                       !    moisture
      double precision cover_fract     ! proportion of maximum cover effect on
                                       !    runoff (0-1)
      double precision cnpd            ! cn proportional in dry range
                                       !    (dul to ll15)
      integer    layer                 ! layer counter

      double precision s               ! potential max retention
                                       !    (surface ponding + infiltration)
      double precision xpb             ! intermedite variable for deriving
                                       !    runof
*
      double precision runoff_wf(0:M)  ! weighting factor for depth for each la
      double precision tillage_reduction  ! reduction in cn due to tillage
      double precision cn2_new
      
*- Implementation Section ----------------------------------

            ! revision of the runoff calculation according to scs curve number
            ! cnpd  : fractional avail. soil water weighted over the
            !         hyd.eff. depth  <dms 7-7-95>
            ! cn1   : curve number for dry soil
            ! cn3   : curve number for wet soil
            ! s     : s value from scs equation, transfer to mm scale
            !         = max. pot. retention (~infiltration) (mm)

           ! check if hydro_effective_depth applies for eroded profile.

      call apswim_runoff_depth_factor (runoff_wf)

      cnpd = 0d0
      do 100 layer = 0, p%n
         cnpd = cnpd
     :        +(g%th(layer)-p%ll15(layer))/(p%dul(layer)-p%ll15(layer))
     :        * runoff_wf(layer)
  100 continue
      cnpd = Min(Max(cnpd, 0d0), 1d0)

          ! reduce CN2 for the day due to cover effect

      cover_fract = ddivide (g%cover_surface_runoff, p%cn_cov, 0d0)
      cover_fract = Min(Max(cover_fract, 0d0), 1d0)

      cn2_new = p%cn2_bare - (p%cn_red * cover_fract)

      cn2_new = Min(Max(cn2_new, 0d0), 100d0)

      cn1 = ddivide (cn2_new, (2.334d0 - 0.01334d0*cn2_new), 0.0d0)
      cn3 = ddivide (cn2_new, (0.4036d0 + 0.005964d0*cn2_new), 0.0d0)
      cn = cn1 + (cn3 - cn1) *cnpd

          ! curve number will be decided from scs curve number table ??dms

      s = 254.0d0* (ddivide (100.0d0, cn, 1000000.0d0) - 1.0d0)
      xpb = rain - 0.2d0*s
      xpb = Max(xpb, 0.0d0)

      runoff = (xpb*xpb)/(rain + 0.8d0*s)

c      call bound_check_real_var (runoff
c     :                          ,0.0
c     :                          ,rain
c     :                          ,'runoff')

      return
      end subroutine

* ====================================================================
       integer function find_swim_layer (depth)
* ====================================================================       

      implicit none

       double precision depth
       integer i
       find_swim_layer = p%n

       do 100 i = 0, p%n
         if (sum(p%dlayer(0:i)).gt.depth) then
            find_swim_layer = i
            goto 200
         endif
  100  continue
   
  200  continue
   
       return
       end function
* ====================================================================
       subroutine apswim_runoff_depth_factor (runoff_wf)
* ====================================================================

      implicit none

*+  Sub-Program Arguments
      double precision runoff_wf(0:M)              ! (OUTPUT) weighting factor for runoff

*+  Purpose
*      Calculate the weighting factor hydraulic effectiveness used
*      to weight the effect of soil moisture on runoff.

*+  Local Variables
      double precision  profile_depth         ! current depth of soil profile
                                       ! - for when erosion turned on
      double precision  cum_depth             ! cumulative depth (mm)
      double precision  hydrol_effective_depth ! hydrologically effective depth for
                                        ! runoff (mm)
      integer    hydrol_effective_layer ! layer number that the effective
                                        ! depth occurs in ()
      integer    layer                 ! layer counter

      double precision  scale_fact     ! scaling factor for wf function to
                                       ! sum to 1
      double precision  wf_tot         ! total of wf ()
      double precision  wx             ! depth weighting factor for current
                                       !    total depth.
                                       !    intermediate variable for
                                       !    deriving wf
                                       !    (total wfs to current layer)
      double precision  xx             ! intermediate variable for deriving wf
                                       ! total wfs to previous layer

*- Implementation Section ----------------------------------

      runoff_wf (0:M) = 0.0
      xx     = 0.0
      cum_depth = 0.0
      wf_tot = 0.0

           ! check if hydro_effective_depth applies for eroded profile.

      profile_depth = sum(p%dlayer(0:p%n))
      
      hydrol_effective_depth = min (c%hydrol_effective_depth
     :                            , profile_depth)

      scale_fact = 1d0/(1d0 - exp(-4.16d0))
      hydrol_effective_layer = find_swim_layer (hydrol_effective_depth)

      do 100 layer = 0, hydrol_effective_layer
         cum_depth = cum_depth + p%dlayer(layer)
         cum_depth = min (cum_depth, hydrol_effective_depth)

            ! assume water content to c%hydrol_effective_depth affects runoff
            ! sum of wf should = 1 - may need to be bounded? <dms 7-7-95>

         wx = scale_fact 
     :      * (1d0 - exp( - 4.16d0* cum_depth/hydrol_effective_depth))
         runoff_wf(layer) = wx - xx
         xx = wx

         wf_tot = wf_tot + runoff_wf(layer)

  100 continue

      call bound_check_double_var (wf_tot, 0.9999d0, 1.0001d0, 'wf_tot')

      return
      end subroutine


      include 'Swim.for'

      end module APSwimModule

!     ===========================================================
      subroutine alloc_dealloc_instance(doAllocate)
!     ===========================================================
      use APSwimModule
      implicit none
      ml_external alloc_dealloc_instance
!STDCALL(alloc_dealloc_instance)

!+  Sub-Program Arguments
      logical, intent(in) :: doAllocate

!+  Purpose
!      Module instantiation routine.

!- Implementation Section ----------------------------------

      if (doAllocate) then
         allocate(g)
         allocate(p)
         allocate(c)
         allocate(id)
      else
         deallocate(g)
         deallocate(p)
         deallocate(c)
         deallocate(id)
      end if
      return
      end subroutine



* ====================================================================
       subroutine Main (Action, Data_string)
* ====================================================================


      use APSwimModule
      implicit none
      ml_external Main


*+  Sub-Program Arguments
       character Action*(*)            ! Message action to perform
       character Data_String*(*)       ! Message data

*+  Purpose
*      This routine is the interface between the main system and the
*      apswim module.

*- Implementation Section ----------------------------------

      if (Action.eq.ACTION_Get_variable) then
         call apswim_Send_my_variable (Data_string)

      else if (Action.eq.ACTION_Create) then
         call doRegistrations(id)
         call apswim_zero_module_links()
         call apswim_zero_variables()

      else if (Action.eq.ACTION_Init) then
         !call apswim_zero_module_links()
         call apswim_Init ()
         call apswim_sum_report ()

      else if ((Action.eq.ACTION_reset)
     :         .or.(Action.eq.ACTION_init)) then
         call apswim_Reset ()

      else if (action.eq.ACTION_sum_report) then
         call apswim_sum_report ()

      else if (Action .eq. ACTION_Prepare) then
         call apswim_prepare ()

      else if (Action.eq.ACTION_Process) then
         call apswim_Process ()

      else if (Action .eq. ACTION_Set_variable) then
         call apswim_set_my_variable (Data_string)

      else if (action.eq.EVENT_irrigated) then
               ! respond to addition of irrigation
         call apswim_ONirrigated ()

      else if (action.eq.'add_water') then
         call fatal_error (ERR_USER,
     :   '"ADD_WATER" message no longer available - use "irrigated"')

      else if (Action .eq. ACTION_Till) then
         call apswim_tillage ()

      else if (Action .eq. 'subsurfaceflow') then
         call apswim_OnSubSurfaceFlow()
      else
         ! Don't use message
         call Message_Unused ()
      endif

      return
      end subroutine
      ! ====================================================================
      ! do first stage initialisation stuff.
      ! ====================================================================
      subroutine doInit1 ()

      use APSwimModule

      ml_external doInit1
!STDCALL(doInit1)

      call doRegistrations(id)
      call apswim_zero_module_links()
      call apswim_zero_variables()
      end subroutine
! ====================================================================
! This routine is the event handler for all events
! ====================================================================
      subroutine respondToEvent(fromID, eventID, variant)

      Use ApswimModule
      implicit none
      ml_external respondToEvent
!STDCALL(respondToEvent)

      integer, intent(in) :: fromID
      integer, intent(in) :: eventID
      integer, intent(in) :: variant

      if (eventID .eq. id%tick) then
         call apswim_ONtick (variant)
      elseif (eventID .eq. id%new_solute) then
         call apswim_on_new_solute(variant, fromID)
      elseif (eventID .eq. id%newcrop) then
         call apswim_OnNewCrop(variant, fromID)
      elseif (eventID .eq. id%cropending) then
         call apswim_OnCropEnding(variant)
      elseif (eventID .eq. id%CohortWaterDemand) then
         call apswim_OnCohortWaterDemand(variant, fromID)
      elseif (eventID .eq. id%prenewmet) then
!         call apswim_set_rain_variable ()
!      elseif (eventID .eq. id%subsurfaceflow) then
!         call apswim_OnSubSurfaceFlow(variant)
      endif
      return
      end subroutine respondToEvent


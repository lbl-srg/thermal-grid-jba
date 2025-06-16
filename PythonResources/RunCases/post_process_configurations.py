import os
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

import numpy as np

plt.rcParams['axes.facecolor']='whitesmoke'
plt.rcParams['font.size'] = 8
plt.rcParams['lines.linewidth'] = 1
plt.rcParams['text.usetex'] = False
plt.rcParams['legend.facecolor'] = 'white'
plt.rcParams['legend.framealpha'] = 0.75
plt.rcParams['legend.edgecolor'] = 'none'
plt.rcParams['savefig.dpi'] = 300

def save_plot(figure, file_name):
    """ Save the figure to a pdf and png file in the directory `img`
    """
    import os
    import matplotlib.pyplot as plt

    out_dir = "img"
    if not os.path.exists(out_dir):
        os.makedirs(out_dir)
    figure.savefig(os.path.join(out_dir, '{}.pdf'.format(file_name)), bbox_inches='tight')
    figure.savefig(os.path.join(out_dir, '{}.png'.format(file_name)), bbox_inches='tight')
    plt.clf()


def configure_axes(axes):
    """ Configure the axis style
    """
    axes.spines['right'].set_visible(False)
    axes.spines['top'].set_visible(False)
    axes.spines['left'].set_visible(False)
    axes.spines['bottom'].set_visible(False)
    axes.grid(color='lightgrey', linewidth=0.25)
    return

def get_results(case_name: str):
    """ Get the results for the case with name `case_name`
    """
    import os
    import cases

    from buildingspy.io.outputfile import Reader
    # Make sure simulation was successful
    dslog_name = os.path.join("simulations", case_name, "dslog.txt")
    with open(dslog_name) as dslog:
       if not "Integration terminated successfully" in dslog.read():
           raise Exception("Simulation failed. Check {}".format(dslog_name))
    file_name = cases.get_result_file_name(case_name)
#     file_name = os.path.join("simulations", "DetailedPlantFiveHubs.mat")
    return Reader(file_name, "dymola")

def get_partial_results(case_name, list_of_variables):
    """ Get a dictionary with the variable names and the time series for `list_of_variables`
    """
    reader = get_results(case_name)
    d = dict()
    read_time = True
    for v in list_of_variables:
        if read_time:
            d['time'] = reader.values(v)[0]
            read_time = False
        d[v] = reader.values(v)[1]
    return d

# ---------------------------------------------------------------------------
# helper functions and scripts

def set_title(ax, title):
    left, width = .01, .97
    bottom, height = .01, .88
    right = left + width
    top = bottom + height

    title_str = r"$\it{" + title + "}$"
    ax.text(left, top,
            title_str,
            verticalalignment = 'center',
            horizontalalignment = 'left',
            transform=ax.transAxes,
            fontsize = 6, color = 'k',
            bbox=dict(facecolor='white', alpha=0.75, edgecolor='none'))


def tem_conv_CtoF(T_in_degC):
    '''Converts temperature provided in degC to degF
    '''
    T_in_degF = (T_in_degC)*9./5. + 32.

    return T_in_degF

def add_secondary_yaxis_for_degF(ax, time, temp_in_K):
        # Add a secondary axis with temperatures represented in F
        ax_F = ax.twinx()
        # Get limits to match with the left axis
        ax_F.set_ylim([tem_conv_CtoF(ax.get_ylim()[0]),tem_conv_CtoF(ax.get_ylim()[1])])
        # plot a "scaler" variable and make it invisible
        ax_F.plot(time, tem_conv_CtoF(temp_in_K-273.15), linewidth=0.0)
        ax_F.set_ylabel('temperature [$^\\circ$F]')
        configure_axes(ax_F)
        #ax.grid(False)
        #ax.xaxis.grid()

def hide_tick_labels(ax):
    '''Removes labels and ticks. Kwargs: bottom controls the ticks, labelbottom the tick labels
    '''
    ax.tick_params(axis = 'x',labelbottom='off',bottom='off')




def plot_energy(cases : list):
    import os
    import matplotlib.pyplot as plt
    import numpy as np

    from buildingspy.io.outputfile import Reader

    plt.clf()

    results = []
    case_names = []
    labels = []
    for cas in cases:
        if cas['postProcess']:
            results.append(cas['reader'])
            case_names.append(cas['name'])
            labels.append(cas['label'])

    n = len(results)
    # Conversion from J to kWh/m2

    AFlo = results[0].max('datDis.AFlo')
    #conv = 1/3600./1000./AFlo
    conv = 1/3600./1E9
    width = 0.5       # the width of the bars: can also be len(x) sequence

    EPvBat = np.zeros(n)
    EHeaPum = np.zeros(n)
    EComPla = np.zeros(n)
    EPumETS = np.zeros(n)
    EPumDis = np.zeros(n)
    EPumPla = np.zeros(n)
    EFanDry = np.zeros(n)
    EFanBui = np.zeros(n)
    EEleNon = np.zeros(n)
    EAllTot = np.zeros(n)


    idx = np.array([i for i in range(n)])
    for i in idx:
        res = results[i]

        EPvBat[i]         = res.min('EPvBat.y') * conv
        EHeaPum[i]        = res.max('EHeaPum.y') * conv
        EComPla[i]        = res.max('EComPla.y') * conv
        EPumETS[i]        = res.max('EPumETS.y') * conv
        EPumDis[i]        = res.max('EPumDis.y') * conv
        EPumPla[i]        = res.max('EPumPla.y') * conv
        EFanDry[i]        = res.max('EFanDryCoo.y') * conv
        EFanBui[i]        = res.max('EFanBui.y') * conv
        EEleNon[i]        = res.max('EEleNonHvaETS.y') * conv
        EAllTot[i]        = res.max('ETot.y') * conv

    bottom = np.zeros(n)
#    pM1 = plt.bar(idx, EPvBat, width, bottom=bottom, zorder=3)
#    bottom = np.add(bottom, EPvBat)
    p0 = plt.bar(idx, EHeaPum, width, bottom=EPvBat, zorder=3)
    bottom = np.add(EPvBat, EHeaPum)
    p1 = plt.bar(idx, EComPla, width, bottom=bottom, zorder=3)
    bottom = np.add(bottom, EComPla)
    p2 = plt.bar(idx, EPumETS, width, bottom=bottom, zorder=3)
    bottom = np.add(bottom, EPumETS)
    p3 = plt.bar(idx, EPumDis, width, bottom=bottom, zorder=3)
    bottom = np.add(bottom, EPumDis)
    p4 = plt.bar(idx, EPumPla, width, bottom=bottom, zorder=3)
    bottom = np.add(bottom, EPumPla)
    p5 = plt.bar(idx, EFanDry, width, bottom=bottom, zorder=3)
    bottom = np.add(bottom, EFanDry)
    p6 = plt.bar(idx, EFanBui, width, bottom=bottom, zorder=3)
    bottom = np.add(bottom, EFanBui)
    p7 = plt.bar(idx, EEleNon, width, bottom=bottom, zorder=3)
    bottom = np.add(bottom, EEleNon)
#    n1 = plt.bar(idx, -EPvBat, width, bottom=EPvBat, zorder=3)
#    n2 = plt.bar(idx, EPvBat+EAllTot)

    print(f"All electricity use = {EAllTot}")
    print(f"Sum of plot = {bottom}")
    np.testing.assert_allclose(EAllTot, bottom, err_msg="Expected energy to be the same.")

    plt.yticks(np.arange(-12, 16, 2))
    plt.grid(linestyle='-', axis='y', zorder=0)
    #plt.ylabel('site electricity use $\mathrm{[kWh/(m^2 \cdot a)]}$')
    plt.ylabel('site electricity use $\mathrm{[GWh/a]}$')
    plt.xticks(idx, labels, rotation=90)
    plt.tick_params(axis=u'x', which=u'both',length=0)

    plt.legend(tuple(reversed((p0[0], p1[0], p2[0], p3[0], p4[0], p5[0], p6[0], p7[0]))), \
               tuple(reversed(('PVs and batteries', 'heat pumps in ETS', 'heat pump in plant', 'pumps in ETS', 'pumps for district loop', 'pumps in  plant', 'fans in plant', 'fans in buildings', 'non-HVAC electricity for buildings'))), \
               bbox_to_anchor=(1.5, 0.75), loc='right')
    #plt.tight_layout()

    save_plot(plt, f"energy")

    # Write result to console and file
    # heat pumps ets
    # heat pumps in plant
    # pumps and fans
    # non-hvac electricity for buildings
    # Total
    # Energy [GWh/a] Energy [kWh/(m a)] Energy costs [USD/a]  Energy costs [USD/(m2 a)]
    #
    k=0
    GWH_to_kWh_m2 = 1E9/AFlo/1000
    head=u"""
\\begin{tabular}{ld{3.2}d{3.2}}
 &  \\multicolumn{1}{l}{Energy} &
 \\multicolumn{1}{l}{Specific energy} \\\\
 &
 \\multicolumn{1}{l}{$\mathrm{[GWh/a]}$} &
 \\multicolumn{1}{l}{$\mathrm{[kWh/(m2 \, a)]}$} \\\\ \hline"""

    vals=f"""
Heat pumps in ETS   & {EHeaPum[k]:.2f} &  {EHeaPum[k]*GWH_to_kWh_m2:.1f} \\\\
Heat pumps in plant & {EComPla[k]:.2f} &  {EComPla[k]*GWH_to_kWh_m2:.1f} \\\\
Pumps               & {(EPumETS[k]+EPumDis[k]+EPumPla[k]):.2f} &  {(EPumETS[k]+EPumDis[k]+EPumPla[k])*GWH_to_kWh_m2:.1f} \\\\
Fans                & {(EFanDry[k]+EFanBui[k]):.2f} &  {(EFanDry[k]+EFanBui[k])*GWH_to_kWh_m2:.1f} \\\\
Non-HVAC electricity for buildings & {EEleNon[k]:.2f} &  {EEleNon[k]*GWH_to_kWh_m2:.1f}  \\\\ \hline
PVs and batteries  & {EPvBat[k]:.2f} &  {EPvBat[k]*GWH_to_kWh_m2:.1f} \\\\
Total & {EAllTot[k]:.2f} &  {EAllTot[k]*GWH_to_kWh_m2:.1f} \\\\ \hline"""
    foot=u"""
    \end{tabular}
    """
    print(vals)
    tab=head + vals + foot
    with open(os.path.join("img", "energyUseMod.tex"), 'w') as f:
        f.write(tab)


def plot_loop_temperatures(cases : list):
    from buildingspy.io.outputfile import Reader
    import matplotlib.pyplot as plt

    results = []
    case_names = []
    for cas in cases:
        if cas['postProcess']:
            results.append(cas['reader'])
            case_names.append(cas['name'])

    nCas = len(case_names)

    for i in range(nCas):

        plt.clf()

        (tP, TDryBul)     = results[i].values('weaBus.TDryBul')
        (tP, TLooMin)     = results[i].values('cenPla.TLooMin')
        (tP, TLooMax)     = results[i].values('cenPla.TLooMax')
        (t, TLooMinMea)   = results[i].values('cenPla.TLooMinMea')
        (t, TLooMaxMea)   = results[i].values('cenPla.TLooMaxMea')
        (t, TDisWatSup)      = results[i].values('TDisWatSup.T')
        (t, TDisWatRet)      = results[i].values('TDisWatRet.T')
        (t, TSoiPer)      = results[i].values('dTSoiPer.T')
        (t, TSoiCen)      = results[i].values('dTSoiCen.T')

        fig, axs = plt.subplots(nrows=3, ncols=1, sharex=True)

        axs[0].plot(t/24./3600., TDryBul-273.15, 'k', label='Outside air temperature', linewidth=0.1)
        axs[0].plot(t/24./3600., TLooMaxMea-273.15, 'r', label='Maximum loop temperature', linewidth=0.2)
        axs[0].plot(t/24./3600., TLooMinMea-273.15, 'b', label='Minimum loop temperature', linewidth=0.2)

        rect1 = matplotlib.patches.Rectangle((tP[0], 0), 365, TLooMin[0]-273.15, color='mistyrose')
        axs[0].add_patch(rect1)
        rect1 = matplotlib.patches.Rectangle((tP[0], TLooMax[0]-273.15), 365, 30, color='mistyrose')
        axs[0].add_patch(rect1)

        axs[0].set_ylabel(r'Temperature [$^\circ$C]')
        #axs[0].set_xticks(list(range(25)))
        axs[0].set_xlim([0, 365])
        axs[0].set_ylim([-13, 42])
        axs[0].legend(bbox_to_anchor=(1.05, 1.0), loc='upper left')
        #ax.set_aspect(5)
        configure_axes(axs[0])

        # Plant
#        axs[1].plot(t/24./3600., TDisWatSup-273.15, 'g', label='Supply temperature to district', linewidth=0.1)
        axs[1].plot(t/24./3600., TDisWatRet-273.15, 'k', label='Return temperature from district loop', linewidth=0.2)
        axs[1].plot(t/24./3600., TSoiPer-273.15, 'r',   marker=",", label='Spatially averaged temperature perimeter borefield', linewidth=0.75, markevery=30000, markersize=3)
        axs[1].plot(t/24./3600., TSoiCen-273.15, 'b',   marker=">", label='Spatially averaged temperature center borefield', linewidth=0.75, markevery=30000, markersize=3)

        rect1 = matplotlib.patches.Rectangle((tP[0], 0), 365, TLooMin[0]-273.15, color='mistyrose')
        axs[1].add_patch(rect1)
        rect1 = matplotlib.patches.Rectangle((tP[0], TLooMax[0]-273.15), 365, 30, color='mistyrose')
        axs[1].add_patch(rect1)

        axs[1].set_ylabel(r'Temperature [$^\circ$C]')
        #axs[0].set_xticks(list(range(25)))
        axs[1].set_xlim([0, 365])
        axs[1].set_ylim([5, 25])
        axs[1].legend(bbox_to_anchor=(1.05, 1.0), loc='upper left')
        #ax.set_aspect(5)
        configure_axes(axs[1])


        # Energy
        (t, EETS)     = results[i].values('ETotEts.y')
        (t, EHexDry)  = results[i].values('cenPla.EHexEne.y')
        (t, EBorCen)  = results[i].values('dTSoiCen.E')
        (t, EBorPer)  = results[i].values('dTSoiPer.E')
        (t, EHPCen)   = results[i].values('cenPla.EHeaPum.y')
        QPip = np.zeros(len(t))
        for k in range(1, 6):
            (_, tmp)     = results[i].values(f'dis.heatPorts[{k}].Q_flow')
            QPip = np.add(QPip, tmp)

        EPip = np.zeros(len(t))
        for k in range(len(t)-1):
            EPip[k+1] = EPip[k] + (QPip[k+1]+QPip[k])/2.*(t[k+1]-t[k])

        axs[2].plot(t/24./3600., -EETS/3600./1E9,    'k--+',     label='Energy from ETS heat exchanger', linewidth=0.2, markevery=60000, markersize=3)
        axs[2].plot(t/24./3600., EHexDry/3600./1E9,  'k-*', label='Energy from central plant economizer', linewidth=0.2, markevery=30000, markersize=3)
        axs[2].plot(t/24./3600., -EBorPer/3600./1E9, 'r',   marker=",", label='Energy from perimeter borefield', linewidth=0.75, markevery=30000, markersize=3)
        axs[2].plot(t/24./3600., -EBorCen/3600./1E9, 'b',   marker=">", label='Energy from center borefield', linewidth=0.75, markevery=30000, markersize=3)
        axs[2].plot(t/24./3600., EPip/3600./1E9,     'g-o',   label='Energy from soil into distribution pipe', linewidth=0.2, markevery=50000, markersize=3)
        axs[2].plot(t/24./3600., EHPCen/3600./1E9,   'k',   marker="<", label='Energy from central heat pump', linewidth=0.5, markevery=60000, markersize=3)


        axs[2].set_xlabel('Time [d]')
        axs[2].set_ylabel('Energy [GWh/a]')
        #axs[2].set_xticks(list(range(25)))
        axs[2].set_xlim([0, 365])
        axs[2].set_ylim([-12, 12])
        axs[2].legend(bbox_to_anchor=(1.05, 1.0), loc='upper left')
        plt.tight_layout()
        configure_axes(axs[2])

        #plt.title()

        save_plot(plt, f"{case_names[i]}_loopTemperatures")


def plotPlant(lis, res, filePrefix, days, time="hours"):
    from datetime import datetime

    ori_font_size = plt.rcParams['font.size']
    plt.rcParams['font.size'] = 4

    def get_minMaxIndex(tMin, tMax, t):
        iSta = 0
        for i in range(len(t)):
            if tMin >= t[i]:
                iSta = i
            else:
                break
        iEnd = 0
        for i in range(len(t)):
            if tMax >= t[i]:
                iEnd = i
            else:
                break

        return (iSta, iEnd)

    for day in days:
        plt.clf()

        tMin = day["xlim"][0]*24*3600.
        tMax = day["xlim"][1]*24*3600.
        (t, ySea) = res.values('cenPla.gen.ind.ySea')
        (iSta, iEnd) = get_minMaxIndex(tMin, tMax, t)

        # Take max so that axs is an array.
        fig, axs = plt.subplots(nrows=len(lis), ncols=1, sharex=True)
        k=0
        if time == "days":
            timeDiv = 3600*24.
        else:
            timeDiv = 3600.
        for i in range(len(lis)):
            for iVar in range(len(lis[i]["vars"])):
                ptrVar = lis[i]["vars"][iVar]
                (tAll, yAll) = res.values(ptrVar["var"])
                t = tAll[iSta:iEnd]
                y = yAll[iSta:iEnd]
                # Check if data series should be skipped to allow for seasonal configuration
                if not (("skip_if_ySea" in ptrVar) and (ptrVar["skip_if_ySea"] == ySea[iSta])):
                    axs[k].plot(t/timeDiv, y * lis[i]["factor"] + lis[i]["offset"], label=ptrVar["label"],
                            linewidth=ptrVar["linewidth"] if "linewidth" in ptrVar else 0.2,
                            linestyle=ptrVar["linestyle"] if "linestyle" in ptrVar else "-",
                            marker=ptrVar["marker"] if "marker" in ptrVar else "",
                            markersize=2,
                            markevery=50)

            #axs[k].set_xlim([tMin, tMax])
            #axs[i].set_ylim([5, 25])
            axs[k].autoscale(True)
            configure_axes(axs[k])

            if iVar == len(lis[i]["vars"])-1:
                # Last variable to be plotted
                if i == len(lis)-1:
                    if time == "days":
                        axs[k].set_xlabel(f"time [day]")
                    else:
                        axs[k].set_xlabel(f"time [h] ({day['date']})")
                    

                axs[k].set_ylabel(lis[i]["y_label"], multialignment='center')
                axs[k].legend(bbox_to_anchor=(1.25, 1.0),
                              loc='upper right',
                              ncol=2)
            #axs[i].set_ylim(lis[i]["y_lim"])

            k=k+1

        #fig.tight_layout()

        save_plot(plt, f"{filePrefix}{day['name']}")
        plt.rcParams['font.size'] = ori_font_size


def plotOneFigure(lis, res, filePrefix, days):
    from datetime import datetime

    ori_font_size = plt.rcParams['font.size']
    plt.rcParams['font.size'] = 8

    def get_minMaxIndex(tMin, tMax, t):
        iSta = 0
        for i in range(len(t)):
            if tMin >= t[i]:
                iSta = i
            else:
                break
        iEnd = 0
        for i in range(len(t)):
            if tMax >= t[i]:
                iEnd = i
            else:
                break

        return (iSta, iEnd)

    for day in days:
        plt.clf()

        tMin = day["xlim"][0]*24*3600.
        tMax = day["xlim"][1]*24*3600.
        (t, ySea) = res.values('cenPla.gen.ind.ySea')
        (iSta, iEnd) = get_minMaxIndex(tMin, tMax, t)

        # Take max so that axs is an array.
        fig, axs = plt.subplots(nrows=len(lis), ncols=1, sharex=True)
        k=0
        for i in range(len(lis)):
            for iVar in range(len(lis[i]["vars"])):
                ptrVar = lis[i]["vars"][iVar]
                (tAll, yAll) = res.values(ptrVar["var"])
                t = tAll[iSta:iEnd]
                y = yAll[iSta:iEnd]
                # Check if data series should be skipped to allow for seasonal configuration
                if not (("skip_if_ySea" in ptrVar) and (ptrVar["skip_if_ySea"] == ySea[iSta])):
                    axs.plot(t/3600./24., y * lis[i]["factor"] + lis[i]["offset"], label=ptrVar["label"],
                            linewidth=ptrVar["linewidth"] if "linewidth" in ptrVar else 0.2,
                            linestyle=ptrVar["linestyle"] if "linestyle" in ptrVar else "-",
                            marker=ptrVar["marker"] if "marker" in ptrVar else "",
                            markersize=2,
                            markevery=50)

            #axs[k].set_xlim([tMin, tMax])
            #axs[i].set_ylim([5, 25])
            axs.autoscale(True)
            configure_axes(axs)
            axs.set_aspect(25)

            if iVar == len(lis[i]["vars"])-1:
                # Last variable to be plotted
                if i == len(lis)-1:
                    axs.set_xlabel(f"time [day]")

                axs.set_ylabel(lis[i]["y_label"], multialignment='center')
                axs.legend(#bbox_to_anchor=(1.25, 1.0),
                              loc='lower right',
                              ncol=2)
            #axs[i].set_ylim(lis[i]["y_lim"])

            k=k+1

        #fig.tight_layout()

        save_plot(plt, f"{filePrefix}{day['name']}")
        plt.rcParams['font.size'] = ori_font_size


def convert_hourly(time, valSets):
    import numpy as np

    # find the indexes of the last occurrence of the duplicate time instants
    timeList = list(time)
    uniTim = set(timeList)
    print("Searching final time instances of the iteration ......")
    uniTimInd = [(len(timeList)-1-timeList[::-1].index(x)) for x in uniTim]
    print("-------- end -------")
    uniTimInd.sort()

    # Number of unique time instants
    n_uniTim = len(uniTim)
    uniTimLis = list(uniTim)
    uniTimLis.sort()
    # begin and end index of each hourly range
    print("Searching indexes of the begin and end moment of each hour .......")
    begin = []
    end = []
    for i in range(8760):
        for j in range(n_uniTim):
            if (uniTimLis[j] >= (i*3600)):
                begin.append(j)
                if j > 0:
                    end.append(j-1)
                break
    end.append(n_uniTim-1)
    print("-------- end -------")

    # find the final values after the iteration
    print("Searching final values after the iteration ......")
    setsWithFinalValues = []
    for i in range(len(valSets)):
        ele = valSets[i]
        temp = dict()
        temp['name'] = ele['name']
        temp['value'] = [ele['value'][j] for j in uniTimInd]
        setsWithFinalValues.append(temp)
    print("-------- end -------")

    # find the hourly average values
    print("Searching hourly values ......")
    hourlySets = []
    for i in range(len(setsWithFinalValues)):
        ele = setsWithFinalValues[i]
        hourlyValue = []
        for j in range(len(begin)):
            begInd = begin[j]
            endInd = end[j]
            if ('uSea' in ele['name']):
                hourlyValue.append(ele['value'][begInd])
            else:
                curHouVals = ele['value'][begInd:(endInd+1)]
                hourlyValue.append(np.mean(curHouVals))
        hourlySets.append({"name": ele['name'], "value": hourlyValue})
    print("-------- end -------")
    return hourlySets


def seasonal_specific_heat(result):
    timLog = result["time"]
    datPoi = len(timLog)
    # seaInd = temp_results["cenPla.gen.borCon.uSea"]
    seaInd = {'name': "uSea", 'value': result["cenPla.gen.borCon.uSea"]}
    borSpePer = {'name': "qBorSpePer_flow", 'value': result["cenPla.borFie.qBorSpePer_flow"]}
    borSpeCen = {'name': "qBorSpeCen_flow", 'value': result["cenPla.borFie.qBorSpeCen_flow"]}
    borSpe = {'name': "qBorSpe_flow", 'value': result["cenPla.borFie.qBorSpe_flow"]}

    speHea_hourly=convert_hourly(timLog, [seaInd, borSpePer, borSpeCen, borSpe])
    seaInd_hourly = speHea_hourly[0]
    borSpePer_hourly = speHea_hourly[1]
    borSpeCen_hourly = speHea_hourly[2]
    borSpe_hourly = speHea_hourly[3]

    # heat flow in winter
    win_qBorSpePer = []
    win_qBorSpeCen = []
    win_qBorSpe = []
    # heat flow in spring
    spr_qBorSpePer = []
    spr_qBorSpeCen = []
    spr_qBorSpe = []
    # heat flow in summer
    sum_qBorSpePer = []
    sum_qBorSpeCen = []
    sum_qBorSpe = []
    # heat flow in fall
    fal_qBorSpePer = []
    fal_qBorSpeCen = []
    fal_qBorSpe = []

    for i in range(len(seaInd_hourly['value'])):
        sea = seaInd_hourly['value'][i]
        if sea == 1:
            win_qBorSpePer.append(borSpePer_hourly['value'][i])
            win_qBorSpeCen.append(borSpeCen_hourly['value'][i])
            win_qBorSpe.append(borSpe_hourly['value'][i])
        elif sea == 2:
            spr_qBorSpePer.append(borSpePer_hourly['value'][i])
            spr_qBorSpeCen.append(borSpeCen_hourly['value'][i])
            spr_qBorSpe.append(borSpe_hourly['value'][i])
        elif sea == 3:
            sum_qBorSpePer.append(borSpePer_hourly['value'][i])
            sum_qBorSpeCen.append(borSpeCen_hourly['value'][i])
            sum_qBorSpe.append(borSpe_hourly['value'][i])
        else:
            fal_qBorSpePer.append(borSpePer_hourly['value'][i])
            fal_qBorSpeCen.append(borSpeCen_hourly['value'][i])
            fal_qBorSpe.append(borSpe_hourly['value'][i])
    speHea = dict()
    speHea['win_qBorSpePer']=win_qBorSpePer
    speHea['win_qBorSpeCen']=win_qBorSpeCen
    speHea['win_qBorSpe']=win_qBorSpe
    speHea['spr_qBorSpePer']=spr_qBorSpePer
    speHea['spr_qBorSpeCen']=spr_qBorSpeCen
    speHea['spr_qBorSpe']=spr_qBorSpe

    speHea['sum_qBorSpePer']=sum_qBorSpePer
    speHea['sum_qBorSpeCen']=sum_qBorSpeCen
    speHea['sum_qBorSpe']=sum_qBorSpe
    speHea['fal_qBorSpePer']=fal_qBorSpePer
    speHea['fal_qBorSpeCen']=fal_qBorSpeCen
    speHea['fal_qBorSpe']=fal_qBorSpe

    return speHea


def generate_specific_heat_plots(result: dict, case_name):
    import matplotlib.pyplot as plt
    import numpy as np

    # create dictionary of the specific heat flow rate in each season for each borefield
    speHea = seasonal_specific_heat(result)

    # Creating subplots with multiple histograms
    fig, axes = plt.subplots(nrows=2, ncols=2, figsize=(12, 6))

    axes[0][0].hist(speHea['win_qBorSpePer'], bins=np.arange(-50, 50, 2.5), color='lightgrey', edgecolor='black')
    axes[0][0].set_title('Winter, perimeter borefield')

    axes[0][1].hist(speHea['spr_qBorSpePer'], bins=np.arange(-50, 50, 2.5), color='lightgrey', edgecolor='black')
    axes[0][1].set_title('Spring, perimeter borefield')

    axes[1][0].hist(speHea['sum_qBorSpePer'], bins=np.arange(-50, 50, 2.5), color='lightgrey', edgecolor='black')
    axes[1][0].set_title('Summer, perimeter borefield')

    axes[1][1].hist(speHea['fal_qBorSpePer'], bins=np.arange(-50, 50, 2.5), color='lightgrey', edgecolor='black')
    axes[1][1].set_title('Fall, perimeter borefield')

    # Adding labels and title
    for i in range(2):
        for j in range(2):
            axes[i][j].set_xlabel('Specific heat flow rate [W/m]')
            axes[i][j].set_ylabel('Frequency [h/a]')

    # Adjusting layout for better spacing
    plt.tight_layout()

    save_plot(plt, case_name+"_perimeter_borefield")


    # Creating subplots with multiple histograms
    fig, axes1 = plt.subplots(nrows=2, ncols=2, figsize=(12, 6))

    axes1[0][0].hist(speHea['win_qBorSpeCen'], bins=np.arange(-50, 50, 2.5), color='lightgrey', edgecolor='black')
    axes1[0][0].set_title('Winter, center borefield')

    axes1[0][1].hist(speHea['spr_qBorSpeCen'], bins=np.arange(-50, 50, 2.5), color='lightgrey', edgecolor='black')
    axes1[0][1].set_title('Spring, center borefield')

    axes1[1][0].hist(speHea['sum_qBorSpeCen'], bins=np.arange(-50, 50, 2.5), color='lightgrey', edgecolor='black')
    axes1[1][0].set_title('Summer, center borefield')

    axes1[1][1].hist(speHea['fal_qBorSpeCen'], bins=np.arange(-50, 50, 2.5), color='lightgrey', edgecolor='black')
    axes1[1][1].set_title('Fall, center borefield')

    # Adding labels and title
    for i in range(2):
        for j in range(2):
            axes1[i][j].set_xlabel('Specific heat flow rate [W/m]')
            axes1[i][j].set_ylabel('Frequency [h/a]')

    # Adjusting layout for better spacing
    plt.tight_layout()

    save_plot(plt, case_name+"_center_borefield")


    # Creating subplots with multiple histograms
    fig, axes2 = plt.subplots(nrows=2, ncols=2, figsize=(12, 6))

    axes2[0][0].hist(speHea['win_qBorSpe'], bins=np.arange(-50, 50, 2.5), color='lightgrey', edgecolor='black')
    axes2[0][0].set_title('Winter, both borefields')

    axes2[0][1].hist(speHea['spr_qBorSpe'], bins=np.arange(-50, 50, 2.5), color='lightgrey', edgecolor='black')
    axes2[0][1].set_title('Spring, both borefields')

    axes2[1][0].hist(speHea['sum_qBorSpe'], bins=np.arange(-50, 50, 2.5), color='lightgrey', edgecolor='black')
    axes2[1][0].set_title('Summer, both borefields')

    axes2[1][1].hist(speHea['fal_qBorSpe'], bins=np.arange(-50, 50, 2.5), color='lightgrey', edgecolor='black')
    axes2[1][1].set_title('Fall, both borefields')

    # Adding labels and title
    for i in range(2):
        for j in range(2):
            axes2[i][j].set_xlabel('Specific heat flow rate [W/m]')
            axes2[i][j].set_ylabel('Frequency [h/a]')

    # Adjusting layout for better spacing
    plt.tight_layout()

    save_plot(plt, case_name+"_both_borefields")


def plot_borefield_specific_heat(results : list, case_names: list, list_of_variables: list):
    for i in range(len(results)):
        res = results[i]
        d = dict()
        read_time = True
        for v in list_of_variables:
            if read_time:
                d['time'] = res.values(v)[0]
                read_time=False
            d[v] = res.values(v)[1]
        generate_specific_heat_plots(d, case_names[i])


def dT_hour(time, TLooMin, TLooMax, TLooMinMea, TLooMaxMea):
    import numpy as np
    dT = []
    dTMax = []
    dTMin = []
    for i in range(len(TLooMinMea)):
        dt_max = TLooMaxMea[i] - TLooMax[0]
        dt_min = TLooMin[0] - TLooMinMea[i]
        dTMax.append(dt_max)
        dTMin.append(dt_min)
        dT.append(max(0, dt_min, dt_max))
    dTHou = (np.trapezoid(dT, time)) / 3600
    return dTHou


def _getEquidistantPowerSeries(reader, nSamPerHou=12):
    import numpy as np
    from buildingspy.io.postprocess import Plotter

    def _getPowerFromEnergy(time, energy):
        """ Get power from energy. Energy must be equidistant. """
        lenE=len(energy)
        dTime = time[1]-time[0]
        diffTime = (max(time)-min(time))/(lenE-1)
        if (diffTime - dTime) > 1E-3:
            raise Exception(f"Time is not equidistant: dTime = {dTime}, diffTime = {diffTime}")

        return (energy[1:lenE]-energy[0:lenE-1])/dTime

    tSup=np.linspace(0, 8760*3600, num=8760*nSamPerHou+1)
    (t, ETot) = reader.values('ETot.y')
    (t, EPvBat) = reader.values('EPvBat.y')

    ETotWithOutPV = ETot - EPvBat

    ETotSup      =Plotter.interpolate(tSup, t, ETot)
    EPvBat       =Plotter.interpolate(tSup, t, EPvBat)
    ETotWithOutPV=Plotter.interpolate(tSup, t, ETotWithOutPV)

    lenE=len(ETotSup)

    PTotSup          =_getPowerFromEnergy(tSup, ETotSup)
    PPvBatSup        =_getPowerFromEnergy(tSup, EPvBat)
    PTotWithOutPVSup =_getPowerFromEnergy(tSup, ETotWithOutPV)
    tPlot=tSup[0:lenE-1]

    return (tPlot, PTotSup, PPvBatSup, PTotWithOutPVSup)


def writeElectricalTimeSeries(reader):
    '''
    Write the hourly time series to a csv file for comparison with MILP
    '''
    import csv
    import os
    import numpy as np
    (t, PTot, PPvBat, PTotWithOutPV) = _getEquidistantPowerSeries(reader, nSamPerHou=1)
    header = ["Time [h]",
              "Imported electricity [MW]",
              "Power provided by PVs and batteries [MW]",
              "Total power consumption of all loads [MW]"
              ]
    with open(os.path.join("img", "powerUse.csv"), 'w', newline='') as fil:
        writer = csv.writer(fil)
        writer.writerow(header)

        for i in range(len(t)):
            row = [t[i]/3600., np.round(PTot[i]/1E6, 4), np.round(PPvBat[i]/1E6, 4), np.round(PTotWithOutPV[i]/1E6, 4)]
            writer.writerow(row)
    return

def plotElectricalTimeSeries(reader):
    import matplotlib.pyplot as plt
    import matplotlib.gridspec as gridspec

    (tPlot, PTotSup, PPvBatSup, PTotWithOutPVSup) = _getEquidistantPowerSeries(reader, nSamPerHou=12)
    # Create plots
    plt.clf()

    fig = plt.figure(figsize=(10, 6))
    gs = gridspec.GridSpec(2, 2)
    axs0 = fig.add_subplot(gs[0, :])
    axs0.plot(tPlot/3600/24, PTotWithOutPVSup/1E6, label="Total power consumption of all loads (without PV)",
            linewidth=0.5,
            color="r",
            linestyle="-")
    axs0.plot(tPlot/3600/24, PPvBatSup/1E6, label="Power provided by PVs and batteries",
            linewidth=0.5,
            color="g",
            linestyle="-")
    axs0.plot(tPlot/3600/24, PTotSup/1E6, label="Imported electricity",
            linewidth=0.5,
            color="k",
            linestyle="-")

    axs1 = fig.add_subplot(gs[1, 0])
    axs1.plot(tPlot/3600/24, PTotWithOutPVSup/1E6, label="Total power consumption of all loads (without PV)",
            linewidth=0.5,
            color="r",
            linestyle="-")
    axs1.plot(tPlot/3600/24, PPvBatSup/1E6, label="Power provided by PVs and batteries",
            linewidth=0.5,
            color="g",
            linestyle="-")
    axs1.plot(tPlot/3600/24, PTotSup/1E6, label="Imported electricity",
            linewidth=0.5,
            color="k",
            linestyle="-")

    axs2 = fig.add_subplot(gs[1, 1])
    axs2.plot(tPlot/3600/24, PTotWithOutPVSup/1E6, label="Total power consumption of all loads (without PV)",
            linewidth=0.5,
            color="r",
            linestyle="-")
    axs2.plot(tPlot/3600/24, PPvBatSup/1E6, label="Power provided by PVs and batteries",
            linewidth=0.5,
            color="g",
            linestyle="-")
    axs2.plot(tPlot/3600/24, PTotSup/1E6, label="Imported electricity",
            linewidth=0.5,
            color="k",
            linestyle="-")

    axs0.set_xlim([0, 365])
    axs1.set_xlim([50, 65])
    axs2.set_xlim([205, 220])
    axs1.set_xticks(np.linspace(50, 65, 16))
    axs2.set_xticks(np.linspace(205, 220, 16))

    axs0.legend(#bbox_to_anchor=(1.25, 1.0),
            loc='upper right',
            ncol=2)
    ax = [axs0, axs1, axs2]
    for i in range(len(ax)):    
            ax[i].set_ylim([-8, 15])
    #axs.autoscale(True)
            configure_axes(ax[i])
    #axs.set_aspect(25)

            ax[i].set_xlabel(f"time [day]")

            ax[i].set_ylabel(f"electricity [MW]", multialignment='center')
            
    fig.tight_layout()
    save_plot(plt, f"powerUse")



"""
Function to compute life cycle and other financial parameters
@author: remi
"""
import pandas as pd
import os
import numpy as np



def calc_finance(If, Iv, C, l, alpha):
    r"""

    Parameters
    ----------
    If    : Fixed part of the investment cost
    Iv    : Variable part of the investment cost, cost per unit
    C     : Capacity of the equipment
    l     : Lifetime if the equipment
    alpha : percentage of the investment cost associated with operation and maintenance expenses

    Returns
    -------
    y : TYPE
        DESCRIPTION.

    """
    duration = 20 # of investment, but not life time of equipment
    i = .05 # Interest rate for JBA
    g = .03 # Interest rate for JBA


    r = (i - g) / (1 + g)
    crf = (r * ( 1 + r) ** 20) / (( 1 + r) ** 20 - 1)

    # Investment cost
    I = If + Iv * C

    # Replacement cost
    RC = 0
    l_new = l
    while l_new < duration:
        RC = RC + I / (1 + r) ** l_new
        l_new = l_new + l

    # Salvage revenue
    SR = I * ((l_new - duration) / l) / (1 + r) ** duration

    # O&M
    OM = 0
    for k in np.arange(1, duration + 1):
        OM = OM + alpha * I / (1 + r) ** k

    # Life-cycle cost
    LCC = I + RC - SR + OM

    ALCC = LCC * crf

    return [ALCC, LCC, I, OM, RC, SR, crf]

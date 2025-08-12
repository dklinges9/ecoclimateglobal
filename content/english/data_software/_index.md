---
title: "Data & Software"
description: ""
subtitle: ""
date: 2021-04-08T13:05:29+06:00
draft: false
bg_image: "images/landscape/patagonia_torres2_banner.JPG"
---

{{< image src="/images/logos/DirtClim_logo.png" alt="image" width="450">}}

<br>
<br>

DirtClim is a database of global microclimate hourly timeseries, including air/soil temperature, relative humidity, and soil moisture. DirtClim was developed by assimilating earth observation remote sensing with mechanistic microclimate models, to generate predictions for the non-polar terrestrial surface. Publications describing and providing the data are coming soon! In the meantime, see some of the affiliated publications below:

[Klinges _et al._ 2025 _Frontiers in Ecology and the Environment_](https://onlinelibrary.wiley.com/doi/abs/10.1002/fee.2831)

[Klinges _et al._ 2024 _Global Ecology and Biogeography_](https://onlinelibrary.wiley.com/doi/abs/10.1111/geb.13884)

<br>
<br>

{{< image src="/images/data_software/biosphere_dirtclim.png" alt="image" width="800">}}

<br>
<br>
<br>
<br>
<br>

## <h2 style="text-align: right;"> [Microclimate Sensor Networks: Optimal Deployment Software](https://github.com/dklinges9/Microclimate-Sensor-Networks) </h2>

![image alt = >40](/images/data_software/sensor_networks_figure.png)

<br>
<br>

It can be hard and messy to decide where to deploy wireless environmental sensors. Sometimes you may choose locations in advance of first visit but find them unfeasible when you visit in person. Even worse, many scientists and conservationists have to revisit sensors after deployment, only to find that some of their sensors (possibly located in key unique locations). How to decide where to deploy one's sensors to uniformly sample across environmental variation, and iteratively choose new locations when some locations don't work or sensors fail? We introduced a comprehensive step-by-step practical guide for environmental sensor site selection and network deployment, drawing on experiences from diverse geographic locations and focusing specifically on microclimate sensors as a representative environmental variable. Corresponding paper describing the software [here in Klinges et al. 2025 _Ecological Informatics_](https://www.sciencedirect.com/science/article/pii/S1574954125003851).

<br>
<br>
<br>
<br>
<br>
<br>

## [mcera5 R package](https://github.com/dklinges9/mcera5)

{{< image src="/images/data_software/mcera5_hex.png" alt="image" width="200" height="200">}}

<br>
<br>

We designed an R package to download and process ERA5 gridded climate timeseries data, to be ready for use in microclimate modelling. Corresponding paper describing the package [here in _Methods in Ecology and Evolution_](https://doi.org/10.1111/2041-210X.13877).

<br>
<br>
<br>

## [microclimc R package](https://github.com/ilyamaclean/microclimc)

Most biodiversity lives in microclimates influenced by vegetation, such as forest canopies but also shurblands, meadows, sand savannahs. To help ecologists represent such climate conditions near the earth's surface, _microclimc_ is a mechanistic model, made available through an R package, that leverages first principles physics to predict microclimate above, within, and below the canopy in any terrestrial location on earth. Alongside the microclimate model, several functions are provided to assist data assimilation, as well as different parameterizations to capture a variety of habitats, allowing flexible application even when little is known about the study location. Corresponding paper describing the package [here in _Ecological Modelling_](https://www.sciencedirect.com/science/article/pii/S0304380021001265).

<br>

## [Coastal Carbon Atlas](https://ccrcn.shinyapps.io/CoastalCarbonAtlas/)

<br>

![image alt = >50](/images/data_software/Atlas_banner.png)

<br>

Use this web interface to visualize, query, and download data from the Coastal Carbon Clearinghouse. User base is the community of scientists and land managers engaged in understanding and preserving coastal ecosysems. Backend and frontend both written in R with use of R Shiny and Leaflet basemaps, customization with JavaScript and CSS. Displayed data stored in the [CCRCN Data Library](https://github.com/Smithsonian/CCRCN-Data-Library). See our corresponding paper as well ([Holmquist _et al._ 2024 _Global Change Biology_](https://onlinelibrary.wiley.com/doi/abs/10.1111/gcb.17098)).

<br>
<br>
<br>
<br>
<br>
<br>
<br>

## [Ecological Forecasting Initative Member Map](https://ecological-forecasting-initiative.shinyapps.io/EFI_members/)

<br>

![image alt = <](/images/data_software/efi_map.png)

<br>
<br>

A map of the membership of EFI, the Ecological Forecasting Initiative. Developed primarily by Ben Toh, in collaboration with Toryn, Dave Klinges, and others.

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## [Introduction to Data Curation and Visualization in R](https://serc.si.edu/coastalcarbon/r-coding)

<br>

{{< image src="/images/data_software/RStudio-Logo-Flat.png" alt="image" width="250">}}
<br>
<br>

An introductory tutorial on how to use R and RStudio to download, re-shape, query, summarize, and plot data (in this case, related to the soil biogeochemistry of coastal wetlands). Tutorial written in R and RMarkdown, customization with CSS and HTML.

&nbsp;
&nbsp;

## [Reproducible Research Project Template](https://github.com/dklinges9/Reproducible-Research-Template)

Open-access GitHub repository for use as a template to develop easy-to-follow, reproducible project workflows. See resources and documentation within for helpful tips and practices on developing such a project.

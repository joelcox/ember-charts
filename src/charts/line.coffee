Ember.Charts.LineComponent = Ember.Charts.ChartComponent.extend(
  Ember.Charts.Legend, Ember.Charts.AxesMixin,
  classNames: ['chart-line']

  # ----------------------------------------------------------------------------
  # Time Series Chart Options
  # ----------------------------------------------------------------------------

  # Getters for formatting human-readable labels from provided data
  formatValue: d3.format('.2s')
  formatYear: d3.format('d')

  # Use basis interpolation? Smooths lines but may prevent extrema from being
  # displayed
  interpolate: no

  removeAllSeries: ->
    @get('viewport').selectAll('.series').remove()

  series: Ember.computed ->
    @get('viewport').selectAll('.series').data(@get 'groupedLineData')
  .volatile()

  # ----------------------------------------------------------------------------
  # Data
  # ----------------------------------------------------------------------------

  groupedLineData: Ember.computed ->
    lineData = @get 'data'
    return [] if Ember.isEmpty lineData

    groups = Ember.Charts.Helpers.groupBy lineData, (d) =>
      d.label
    for groupName, values of groups
      group: groupName
      values: values

  .property 'data.@each'

  # Combine all data for testing purposes
  finishedData: Ember.computed ->
    lineData: @get('groupedLineData')
  .property(
    'groupedLineData.@each.values'

  hasNoData: Ember.computed ->
    !@get('hasLineData'))
  .property 'hasLineData'

  hasLineData: Ember.computed ->
    !Ember.isEmpty(@get 'lineData')
  .property 'lineData'

  # ----------------------------------------------------------------------------
  # Layout
  # ----------------------------------------------------------------------------

  # Vertical spacing for legend, x axis labels and x axis title
  legendChartPadding: Ember.computed.alias 'labelHeightOffset'

  graphicLeft: Ember.computed.alias 'labelWidthOffset'

  graphicWidth: Ember.computed ->
    @get('width') - @get('labelWidthOffset')
  .property 'width', 'labelWidthOffset'

  graphicHeight: Ember.computed ->
    @get('height') - @get('legendHeight') - @get('legendChartPadding')
  .property('height', 'legendHeight', 'legendChartPadding')

  # ----------------------------------------------------------------------------
  # Line Drawing Scales
  # ----------------------------------------------------------------------------

  lineSeriesNames: Ember.computed ->
    data = @get 'groupedLineData'
    return [] if Ember.isEmpty(data)
    data.map (d) -> d.group
  .property 'groupedLineData'

  lineDataExtent: Ember.computed ->
    data = @get 'groupedLineData'
    return [new Date(), new Date()] if Ember.isEmpty(data)
    extents = data.getEach('values').map (series) ->
      d3.extent series.map((d) -> d.value)
    [d3.min(extents, (e) -> e[0]), d3.max(extents, (e) -> e[1])]
  .property 'groupedLineData.@each.values'

  # The set of all time series
  xBetweenSeriesDomain: Ember.computed.alias 'lineSeriesNames'

  # The range of all time series
  xWithinSeriesDomain: Ember.computed.alias 'lineDataExtent'

  # ----------------------------------------------------------------------------
  # Ticks and Scales
  # ----------------------------------------------------------------------------

  # Override axis mixin to correct for the amount of years we want to
  # display across the x-axis
  numXTicks: Ember.computed ->
    yearsDomain = @get 'xDomain'
    yearsDomain[1] - yearsDomain[0]
  .property 'xDomain'

  # Create a domain that spans the larger range of line data
  xDomain: Ember.computed ->
    lineData = @get 'groupedLineData'

    maxOfLineData = d3.max lineData, (d) -> d3.max(d.values, (dd) -> dd.group)
    minOfLineData = d3.min lineData, (d) -> d3.min(d.values, (dd) -> dd.group)

    [minOfLineData, maxOfLineData]
  .property('groupedLineData')

  yDomain: Ember.computed ->
    lineData = @get 'groupedLineData'

    maxOfLineData = d3.max lineData, (d) -> d3.max(d.values, (dd) -> dd.value)
    minOfLineData = d3.min lineData, (d) -> d3.min(d.values, (dd) -> dd.value)

    [minOfLineData, maxOfLineData]
  .property('groupedLineData')

  yRange: Ember.computed ->
    [ @get('graphicTop') + @get('graphicHeight'), @get('graphicTop') ]
  .property 'graphicTop', 'graphicHeight'

  yScale: Ember.computed ->
    d3.scale.linear()
      .domain(@get('yDomain'))
      .range(@get('yRange'))
      .nice(@get('numYTicks'))
  .property 'yDomain', 'yRange', 'numYTicks'

  xRange: Ember.computed ->
    [ @get('graphicLeft'), @get('graphicLeft') + @get('graphicWidth') ]
  .property 'graphicLeft', 'graphicWidth'

  xTimeScale: Ember.computed ->
    d3.scale.linear()
      .domain(@get('xDomain'))
      .range(@get('xRange'))
      .nice(@get('numXTicks'))
  .property 'xDomain', 'xRange'

  # ----------------------------------------------------------------------------
  # Styles
  # ----------------------------------------------------------------------------

  line: Ember.computed ->
    d3.svg.line()
      .x((d) => @get('xTimeScale') d.group)
      .y((d) => @get('yScale') d.value)
      .interpolate(if @get('interpolate') then 'basis' else 'linear')
  .property 'xTimeScale', 'yScale', 'interpolate'

  # Line styles. Implements Craig's design spec, which ensures that out of the
  # first six lines, there are always two distinguishing styles between every
  # pair of lines.
  # 1st line: ~2px, base color, solid
  # 2nd line: ~1px, 66% tinted, solid
  # 3rd line: ~2px, base color, dotted
  # 4th line: ~1px, 66% tinted, dotted
  # 5th line: ~3px, 33% tinted, solid
  # 6th line: ~3px, 33% tinted, dotted
  getLineColor: Ember.computed ->
    (d,i) =>
      getSeriesColor = @get 'getSeriesColor'
      switch i
        when 0 then getSeriesColor(d, 0)
        when 1 then getSeriesColor(d, 2)
        when 2 then getSeriesColor(d, 0)
        when 3 then getSeriesColor(d, 2)
        when 4 then getSeriesColor(d, 0)
        when 5 then getSeriesColor(d, 1)
        else        getSeriesColor(d, i)

  lineAttrs: Ember.computed ->
    getSeriesColor = @get 'getSeriesColor'
    line = @get 'line'
    class: (d,i) -> "line series-#{i}"
    d: (d) -> line d.values
    fill: 'none'
    stroke: @get 'getLineColor'
    'stroke-width': (d, i) =>
      switch i
        when 0 then 2
        when 1 then 1.5
        when 2 then 2
        when 3 then 1.5
        when 4 then 2.5
        when 5 then 2.5
        else        2
    'stroke-dasharray': (d, i) =>
      switch i
        when 2,3,5 then '2,2'
        else ''
  .property 'line', 'getSeriesColor'

  # ----------------------------------------------------------------------------
  # Color Configuration
  # ----------------------------------------------------------------------------

  numLines: Ember.computed.alias 'xBetweenSeriesDomain.length'
  numColorSeries: 6 # Ember.computed.alias 'numLines'

  # Use primary colors for bars if there are no lines
  secondaryMinimumTint: Ember.computed ->
    if @get('numLines') is 0 then 0 else 0.4
  .property 'numLines'

  secondaryMaximumTint: Ember.computed ->
    if @get('numLines') is 0 then 0.8 else 0.85
  .property 'numLines'

  # ----------------------------------------------------------------------------
  # Legend Configuration
  # ----------------------------------------------------------------------------

  hasLegend: true,

  legendItems: Ember.computed ->
    getSeriesColor = @get 'getSeriesColor'
    lineAttrs = @get 'lineAttrs'
    @get('xBetweenSeriesDomain').map (d, i) =>
      # Line legend items
      label: d
      stroke: lineAttrs['stroke'](d, i)
      width: lineAttrs['stroke-width'](d, i)
      dotted: lineAttrs['stroke-dasharray'](d, i)
      icon: -> 'line'
      selector: ".series-#{i}"
  .property('xBetweenSeriesDomain',
    'getSeriesColor', 'getSecondarySeriesColor')

  # ----------------------------------------------------------------------------
  # Tooltip overwrites
  # ----------------------------------------------------------------------------

  showLegendDetails: Ember.computed ->
    return ->
      null

  hideLegendDetails: Ember.computed ->
    return ->
      null

  # ----------------------------------------------------------------------------
  # Selections
  # ----------------------------------------------------------------------------

  xAxis: Ember.computed ->
    xAxis = @get('viewport').select('.x.axis')
    if xAxis.empty()
      return @get('viewport')
        .insert('g', ':first-child')
        .attr('class', 'x axis')
    else
      return xAxis
  .volatile()

  yAxis: Ember.computed ->
    yAxis = @get('viewport').select('.y.axis')
    if yAxis.empty()
      return @get('viewport')
        .insert('g', ':first-child')
        .attr('class', 'y axis')
    else
      return yAxis
  .volatile()

  # ----------------------------------------------------------------------------
  # Drawing Functions
  # ----------------------------------------------------------------------------

  renderVars: ['getLabelledTicks', 'xTimeScale', 'yScale']

  drawChart: ->
    @updateLineData()
    @updateAxes()
    @updateLineGraphic()
    if @get('hasLegend')
      @drawLegend()
    else
      @clearLegend()

  updateAxes: ->
    xAxis = d3.svg.axis()
      .scale(@get 'xTimeScale')
      .orient('bottom')
      .ticks(@get 'numXTicks')
      .tickFormat(@get 'formatYear')

    yAxis = d3.svg.axis()
      .scale(@get 'yScale')
      .orient('right')
      .ticks(@get 'numYTicks')
      .tickSize(@get 'graphicWidth')
      .tickFormat(@get 'formatValue')

    graphicTop = @get 'graphicTop'
    graphicHeight = @get 'graphicHeight'
    gXAxis = @get('xAxis')
      .attr(transform: "translate(0,#{graphicTop+graphicHeight})")
      .call(xAxis)

    graphicLeft = @get 'graphicLeft'
    gYAxis = @get('yAxis')
      .attr('transform', "translate(#{graphicLeft},0)")
      .call(yAxis)

    # Ensure ticks other than the zeroline are minor ticks
    gYAxis.selectAll('g')
      .filter((d) -> d)
      .classed('major', no)
      .classed('minor', yes)

    gYAxis.selectAll('text')
      .style('text-anchor', 'end')
      .attr
        x: -@get('labelPadding')

  updateLineData: ->
    # Always remove the previous lines, this allows us to maintain the
    # rendering order of bars behind lines
    @removeAllSeries()

    series = @get 'series'
    series.enter()
      .append('g').attr('class', 'series')
      .append('path').attr('class', 'line')
    series.exit()
      .remove()

  updateLineGraphic: ->
    series = @get 'series'
    graphicTop = @get 'graphicTop'
    series.attr('transform', "translate(0, #{graphicTop})")
    series.select('path.line')
      .attr(@get 'lineAttrs')

)

Ember.Handlebars.helper('line-chart', Ember.Charts.LineComponent)

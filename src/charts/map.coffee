
Ember.Charts.MapComponent = Ember.Charts.ChartComponent.extend(
  Ember.Charts.Legend
  classNames: ['chart-map']

  # ----------------------------------------------------------------------------
  # Data manipulation
  # ----------------------------------------------------------------------------

  values: Ember.computed ->
    @get('data').map (item) =>
      item.value
  .property('data')

  minValue: Ember.computed ->
    d3.min @get 'values'
  .property('values')

  maxValue: Ember.computed ->
    d3.max @get 'values'
  .property('values')

  finishedData: Ember.computed ->
    @get 'data'
  .property('data')

  unit: Ember.computed ->
    (@get('maxValue') - @get('minValue')) / @get('numColorSeries')
  .property('maxValue', 'minValue', 'numColorSeries')

  seriesNumFromValue: Ember.computed ->
    minValue = @get 'minValue'
    maxValue = @get 'maxValue'
    numColorSeries = @get 'numColorSeries'
    unit = @get 'unit'

    (value) ->
      if value == minValue
        return 0
      if value == maxValue
        return numColorSeries - 1
      Math.floor((value - minValue) / unit)

  .property('minValue', 'maxValue', 'numColorSeries', 'unit')

  numColorSeries: 5

  # This is basically the default implementation, only reversed
  # so it makes more sense when assuming that lower values have
  # lighter series color.
  colorScale: Ember.computed ->
    scaleRange = [@get('colorRange')[1], @get('colorRange')[0]]
    @get('colorScaleType')().range(scaleRange)
  .property 'colorRange', 'colorScaleType'

  # ----------------------------------------------------------------------------
  # Selections
  # ----------------------------------------------------------------------------

  countries: Ember.computed ->
    @get('viewport').append('svg:g').attr('id', 'countries')
  .property 'viewport'


  # ----------------------------------------------------------------------------
  # Legend Configuration
  # ----------------------------------------------------------------------------

  hasLegend: Ember.computed ->
    @get('legendItems.length') > 1
  .property 'legendItems.length'

  legendItems: Ember.computed ->
    numColorSeries = @get 'numColorSeries'
    seriesColor = @get 'getSeriesColor'
    maxValue = @get 'maxValue'
    minValue = @get 'minValue'

    bound = (i) ->
      (((maxValue - minValue) / numColorSeries) * i + minValue).toPrecision(4)

    [1..5].map (d, i) =>
      label: bound(i) + ' - ' + bound(i + 1)
      icon: -> 'square'
      fill: seriesColor(d - 1, d - 1)
      width: 2.5

  .property('maxValue', 'minValue', 'unit', 'numColorSeries')


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
  # D3 properties
  # ----------------------------------------------------------------------------

  # Creates a projection of a rectangular equiator projection, using
  # the computed scale
  projection: Ember.computed ->
    d3.geo.equirectangular()
      .scale((@get('width') + 1) / 2 / Math.PI)
      .translate([@get('width') / 2, @get('height') / 1.8])
  .property('width', 'height')

  renderVars: ['countries', 'projection', 'projectionScale', 'finishedData', 'unit']

  drawChart: ->
    filled = 0
    @drawLegend()

    countries = @get('countries').selectAll('path').data(countries_data.features, (d) =>
      d.properties.name
    )

    data = @get 'finishedData'
    seriesColor = @get 'getSeriesColor'
    seriesNumFromValue = @get 'seriesNumFromValue'

    countries_data.features.forEach (item) =>
      filtered = data.findBy('label', item.properties.name)
      if (filtered != undefined)
        item.properties.value = filtered.value

    # Create a new path of the real projection with correct scale
    path = d3.geo.path().projection(@get 'projection')

    # Add a white fill if no value is provided
    fill = (d, i) =>
      filled+1;
      if d.properties.value == undefined
        '#fff'
      else
        seriesColor(d, seriesNumFromValue(d.properties.value))

    # Update everything in the selection
    countries.attr('fill', fill)

    # Create new countries
    countries.enter()
      .append('svg:path')
      .attr('d', path)
      .attr('fill', fill)
      .attr('stroke', 'rgba(0, 0, 0, 0.2)')
      .attr('stroke-width', 1)

    # Remove countries no longer in the map
    countries.exit().remove()

)

Ember.Handlebars.helper('map-chart', Ember.Charts.MapComponent)

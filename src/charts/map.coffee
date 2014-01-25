
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

  # ----------------------------------------------------------------------------
  # Selections
  # ----------------------------------------------------------------------------

  countries: Ember.computed ->
    @get('viewport').append('svg:g').attr('id', 'countries');
  .volatile()


  # ----------------------------------------------------------------------------
  # Legend Configuration
  # ----------------------------------------------------------------------------

  hasLegend: Ember.computed ->
    @get('legendItems.length') > 1
  .property 'legendItems.length'

  legendItems: Ember.computed ->

    unit = (@get('maxValue') - @get('minValue')) / 5
    bound = (i, max, min) ->
      ((max - min) / 5) * i + min

    [1, 2, 3, 4, 5].map (d, i) =>
      label: bound(i, @get('maxValue'), @get('minValue')) + ' - ' + bound(i + 1, @get('maxValue'), @get('minValue'))
      icon: -> 'square'
      fill: 'rgba(0, 0, 0, ' + d * 0.2 +')'
      width: 2.5

  .property('maxValue', 'minValue')


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
      .scale(@get 'projectionScale')
      .translate([@get('width') / 2, @get('height') / 2])
  .property('width', 'height', 'projectionScale')

  path: Ember.computed ->
    d3.geo.path @get 'projection'
  .property('projection')

  # Computes the minimal and maximum bounds of the features
  mapBounds: Ember.computed ->

    # Find the bounds
    path = @get 'bootstrapPath'
    minWidth = maxHeight = maxWidth = minHeight = null

    countries_data.features.forEach (country) =>
      bounds = path.bounds country

      if minWidth < bounds[0][0] or minHeight == null
        minWidth = bounds[0][0]
      if maxHeight < bounds[0][1] or maxHeight == null
        maxHeight = bounds[0][1]
      if maxWidth < bounds[1][0] or maxWidth == null
        maxWidth = bounds[1][0]
      if minHeight > bounds[1][1] or minHeight == null
        minHeight = bounds[1][1]

    [[minWidth, maxHeight], [maxWidth, minHeight]]
  .property()

  projectionScale: Ember.computed ->

    # In order to find the scale, we somehow need to bootstrap a path
    # to get the scale and projection. Not quite sure how to clean this up
    mapBounds = @get 'mapBounds'
    .95 / Math.max((mapBounds[1][0] - mapBounds[0][0]) / @get('width'), (mapBounds[1][1] - mapBounds[0][1]) / @get('height'))
  .property('mapBounds', 'width', 'height')

  # An initial path used to compute the scale
  bootstrapPath: Ember.computed ->

    projection = d3.geo.equirectangular()
       .scale(390)
       .translate([@get('width') / 2, @get('height') / 2])

    d3.geo.path().projection(projection)

  .property('width', 'height')

  colorScale: Ember.computed ->
    d3.scale.quantize()
      .domain([@get 'minValue', @get 'maxValue'])
      .range([1, 2, 3, 4, 5])
  .property('minValue', 'maxValue')

  renderVars: ['countries', 'projection', 'projectionScale']

  drawChart: ->

    @drawLegend()

    countries = @get 'countries'
    data = @get 'finishedData'
    colorScale = @get 'colorScale'

    countries_data.features.forEach (item) =>
      item.properties.value = Math.floor(Math.random() * 100) + 1
      if item.properties.name == 'Germany'
        item.properties.value = 100
      if item.properties.name == 'Belgium'
        item.properties.value = 100
      if item.properties.name == 'France'
        item.properties.value = 100

    # Create a new path of the real projection with correct scale
    path = d3.geo.path().projection(@get 'projection')

    countries.selectAll('path')
      .data(countries_data.features)
      .enter()
      .append('svg:path')
      .attr('d', path)
      .attr('fill', (d) =>
        'rgba(0, 0, 0, ' + d.properties.value * 0.01 +')'
        )
      .attr('stroke', 'rgba(0, 0, 0, 0.2)')
      .attr('stroke-width', 1)

)

Ember.Handlebars.helper('map-chart', Ember.Charts.MapComponent)

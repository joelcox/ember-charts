
Ember.Charts.MapComponent = Ember.Charts.ChartComponent.extend(
  classNames: ['chart-map']

  finishedData: Ember.computed ->
    [
        {
          "label": "GBP growth",
          "group": "Belgium",
          "value": 20
        },
        {
          "label": "GBP growth",
          "group": "Germany",
          "value": 32
        },
        {
          "label": "GBP growth",
          "group": "France",
          "value": 36
        },
    ]

  # Selections
  countries: Ember.computed ->
    @get('viewport').append('svg:g').attr('id', 'countries');
  .volatile()

  # D3 properties

  projection: Ember.computed ->
    d3.geo.albersUsa()
      .scale(1070)
      .translate([@get 'width' / 2, @get 'height' / 2]);
  .property 'width', 'height'

  pathz: Ember.computed ->
    proj = @get 'projection'
    d3.geo.path()
  .property 'projection'

  colorScale: Ember.computed ->
    d3.scale.quantize()
      .domain([0, 100])
      .range([1, 2, 3, 4, 5])
  .property

  renderVars: ['countries', 'projection']

  drawChart: ->

    dat = [
        {
          "label": "GBP growth",
          "group": "Belgium",
          "value": 20
        },
        {
          "label": "GBP growth",
          "group": "Germany",
          "value": 32
        },
        {
          "label": "GBP growth",
          "group": "France",
          "value": 36
        },
    ]

    scale = @get('colorScale')
    scale = d3.scale.quantize()
      .domain([0, 100])
      .range([1, 2, 3, 4, 5])

    countries_data.features.forEach (item) =>
      item.properties.value = Math.floor(Math.random() * 100) + 1
      if item.properties.name == 'Germany'
        item.properties.value = 100
      if item.properties.name == 'Belgium'
        item.properties.value = 100
      if item.properties.name == 'France'
        item.properties.value = 100

    countries = @get 'countries'
    projection = d3.geo.equirectangular()
      .scale(100)
      .translate([@get('width') / 2, @get('height') / 2]);

    path = d3.geo.path().projection(projection)

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

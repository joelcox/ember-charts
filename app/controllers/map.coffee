App.EmberChartsMapController = App.SlideController.extend

  # ---------
  # Data Selection
  # ---------

  availableDataSets: Ember.computed ->
    _.keys @get('rawDataHash')
  .property 'rawDataHash'

  data: Ember.computed ->
    @get('rawDataHash')[@get 'selectedData']
  .property 'selectedData', 'rawDataHash'

  rawDataHash: Ember.computed ->
    map: App.data.map
    map2: App.data.map2
    map3: App.data.map3
    empty: App.data.empty
  selectedData: 'map'

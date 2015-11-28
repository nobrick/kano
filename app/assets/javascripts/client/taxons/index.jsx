import { Component } from 'react';
import { createStore } from 'redux'
import { Provider } from 'react-redux';
import Immutable from 'immutable';
import TaxonContainer from './containers';
import taxons from './reducers';

export default class Taxons extends Component {
  render() {
    let initalStates = Immutable.fromJS(this.props.initial, (key, value) => {
      let isIndexed = Immutable.Iterable.isIndexed(value);
      return isIndexed ? value.toSet() : value.toMap();
    });
    let store = createStore(taxons, initalStates);

    return (
      <Provider store={store}>
        <TaxonContainer />
      </Provider>
    );
  }
}

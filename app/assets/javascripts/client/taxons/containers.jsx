import { Component } from 'react';
import { connect } from 'react-redux';
import { selectTaxon, unselectTaxon } from './actions';
import TaxonList from './components/taxon_list';
import NewTaxon from './components/new_taxon';

class App extends Component {
  render() {
    const { dispatch, taxons, selectedCodes } = this.props;
    return (
      <div className="taxonBox">
        <TaxonList
          taxons={taxons}
          onDeleteClick={code => dispatch(unselectTaxon(code))}
        />
        <NewTaxon onAddClick={code => dispatch(selectTaxon(code))} />
        <input name="taxon_codes" value={selectedCodes} type="hidden" />
      </div>
    );
  }
}

function select(state) {
  const selectedTaxons = state.getIn(['result', 'selectedTaxons']);
  const allTaxons = state.getIn(['result', 'allTaxons']);
  return {
    taxons: selectedTaxons.map(code =>
      state.getIn(['entities', 'taxons', code])
    ).toJS(),
    selectedCodes: selectedTaxons.toJS()
  };
}
export default connect(select)(App);

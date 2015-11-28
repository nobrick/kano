import Immutable from 'immutable';
import { SELECT_TAXON, UNSELECT_TAXON } from './actions';

export default function taxons(state, action) {
  const { type, code } = action
  switch (type) {
    case SELECT_TAXON: {
      return state.updateIn(['result', 'selectedTaxons'], l => l.add(code));
    }
    case UNSELECT_TAXON: {
      return state.updateIn(['result', 'selectedTaxons'], l => l.remove(code));
    }
    default: {
      return state;
    }
  }
}

import { useBackend } from '../backend';
import { Box, Button, LabeledList, Section } from '../components';
import { Window } from '../layouts';

export const CellularEmporium = (props, context) => {
  const { act, data } = useBackend(context);
  const { abilities } = data;
  return (
    <Window width={900} height={480}>
      <Window.Content scrollable>
        <Section>
          <LabeledList>
            <LabeledList.Item
              label="Генетические очки"
              buttons={
                <Button
                  icon="undo"
                  content="Переадаптировать"
                  disabled={!data.can_readapt}
                  onClick={() => act('readapt')}
                />
              }>
              {data.genetic_points_remaining}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section>
          <LabeledList>
            {abilities.map((ability) => (
              <LabeledList.Item
                key={ability.name}
                className="candystripe"
                label={ability.name}
                buttons={
                  <>
                    {ability.dna_cost}{' '}
                    <Button
                      content={ability.owned ? 'Развито' : 'Развить'}
                      selected={ability.owned}
                      onClick={() =>
                        act('evolve', {
                          name: ability.name,
                        })
                      }
                    />
                  </>
                }>
                {ability.desc}
                <Box color="good">{ability.helptext}</Box>
              </LabeledList.Item>
            ))}
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};

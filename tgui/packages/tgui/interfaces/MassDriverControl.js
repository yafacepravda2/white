import { useBackend } from '../backend';
import { Box, Button, Section, LabeledList, NumberInput } from '../components';
import { Window } from '../layouts';

export const MassDriverControl = (props, context) => {
  const { act, data } = useBackend(context);
  const { connected, minutes, seconds, timing, power, poddoor } = data;
  return (
    <Window width={300} height={connected ? 225 : 107}>
      <Window.Content>
        {!!connected && (
          <Section
            title="Авто-запуск"
            buttons={
              <Button
                icon={'clock-o'}
                content={timing ? 'Стоп' : 'Старт'}
                selected={timing}
                onClick={() => act('time')}
              />
            }>
            <Button
              icon="fast-backward"
              disabled={timing}
              onClick={() => act('input', { adjust: -30 })}
            />
            <Button
              icon="backward"
              disabled={timing}
              onClick={() => act('input', { adjust: -1 })}
            />{' '}
            {String(minutes).padStart(2, '0')}:
            {String(seconds).padStart(2, '0')}{' '}
            <Button
              icon="forward"
              disabled={timing}
              onClick={() => act('input', { adjust: 1 })}
            />
            <Button
              icon="fast-forward"
              disabled={timing}
              onClick={() => act('input', { adjust: 30 })}
            />
          </Section>
        )}
        <Section
          title="Управление"
          buttons={
            <Button
              icon={'toggle-on'}
              content="Внешний шлюз"
              disabled={timing || !poddoor}
              onClick={() => act('door')}
            />
          }>
          {(!!connected && (
            <>
              <LabeledList>
                <LabeledList.Item
                  label="Сила"
                  buttons={
                    <Button
                      icon={'bomb'}
                      content="Тест"
                      disabled={timing}
                      onClick={() => act('driver_test')}
                    />
                  }>
                  <NumberInput
                    value={power}
                    width="40px"
                    minValue={0.25}
                    maxValue={16}
                    onChange={(e, value) => {
                      return act('set_power', {
                        power: value,
                      });
                    }}
                  />
                </LabeledList.Item>
              </LabeledList>
              <Button
                fluid
                content="Старт"
                disabled={timing}
                mt={1.5}
                icon="arrow-up"
                textAlign="center"
                onClick={() => act('launch')}
              />
            </>
          )) || <Box color="bad">Не подключен масс-драйвер.</Box>}
        </Section>
      </Window.Content>
    </Window>
  );
};

import express, { Request, Response, Router } from 'express';
import knex from './database/connection'; // Certifique-se que o caminho para a conexão knex está correto


const routes: Router = express.Router();
// --- ROTAS PARA TUTOR ---

// [GET] Listar todos os tutores
routes.get('/tutors', async (request: Request, response: Response) => {
    try {
        const Tutor = await knex('Tutor').select('*');
         response.json(Tutor);
    } catch (error) {
        console.error(error); // É bom logar o erro no servidor
         response.status(500).json({ message: 'Erro ao buscar tutores.', error });
    }
});

// [POST] Criar um novo tutor
routes.post('/tutors', async (request: Request, response: Response) => {
    const { nome, contato, sexo, metodoPagamento } = request.body;
    const trx = await knex.transaction(); // Usar transaction para garantir a integridade

    try {
        const newTutor = { nome, contato, sexo, metodoPagamento };
        const insertedIds = await trx('Tutor').insert(newTutor);
        const tutorId = insertedIds[0];

        await trx.commit();

         response.status(201).json({ id: tutorId, ...newTutor });
    } catch (error) {
        await trx.rollback();
        console.error(error);
         response.status(500).json({ message: 'Erro ao criar tutor.', error });
    }
});

// [PUT] Atualizar um tutor existente
routes.put('/tutors/:id', async (request: Request, response: Response) => {
    const { id } = request.params;
    const { nome, contato, sexo, metodoPagamento } = request.body;

    try {
        const updatedCount = await knex('Tutor')
            .where('id', id)
            .update({ nome, contato, sexo, metodoPagamento });

        if (updatedCount === 0) {
             response.status(404).json({ message: 'Tutor não encontrado.' });
        }

         response.json({ message: 'Tutor atualizado com sucesso.' });
    } catch (error) {
        console.error(error);
         response.status(500).json({ message: 'Erro ao atualizar tutor.', error });
    }
});

// [DELETE] Deletar um tutor
routes.delete('/tutors/:id', async (request: Request, response: Response) => {
    const { id } = request.params;

    try {
        const deletedCount = await knex('Tutor').where('id', id).del();

        if (deletedCount === 0) {
             response.status(404).json({ message: 'Tutor não encontrado.' });
        }

         response.status(204).send(); // 204 No Content é uma resposta padrão para delete
    } catch (error) {
        console.error(error);
         response.status(500).json({ message: 'Erro ao deletar tutor.', error });
    }
});


// --- ROTAS PARA RACA ---

// [GET] Listar todas as raças
routes.get('/racas', async (request: Request, response: Response) => {
    try {
        const racas = await knex('Raca').select('*');
         response.json(racas);
    } catch (error) {
        console.error(error);
         response.status(500).json({ message: 'Erro ao buscar raças.', error });
    }
});

// [GET] Listar raças por espécie (Cachorro ou Gato)
routes.get('/racas/especie/:especie', async (request: Request, response: Response) => {
    const { especie } = request.params;
    try {
        const racas = await knex('Raca').where('especie', especie).select('*');
         response.json(racas);
    } catch (error) {
        console.error(error);
         response.status(500).json({ message: 'Erro ao buscar raças por espécie.', error });
    }
});

// [POST] Criar uma nova raça
routes.post('/racas', async (request: Request, response: Response) => {
    const { nome, especie } = request.body;
    
    try {
        const newRaca = { nome, especie };
        const insertedIds = await knex('Raca').insert(newRaca);
        const racaId = insertedIds[0];
        
         response.status(201).json({ id: racaId, ...newRaca });
    } catch (error) {
        console.error(error);
         response.status(500).json({ message: 'Erro ao criar raça.', error });
    }
});


// --- ROTAS PARA PET ---

// [GET] Listar todos os pets
routes.get('/pets', async (request: Request, response: Response) => {
    try {
        const pets = await knex('Pet')
            .join('Tutor', 'Pet.tutorId', '=', 'Tutor.id')
            .join('Raca', 'Pet.racaId', '=', 'Raca.id')
            .select(
                'Pet.*',
                'Tutor.nome as nomeTutor',
                'Tutor.contato as contatoTutor',         // <-- Verifique esta linha
                'Tutor.sexo as sexoTutor',             // <-- Verifique esta linha
                'Tutor.metodoPagamento as pagamentoTutor', // <-- Verifique esta linha
                'Raca.nome as nomeRaca'
            );
        response.json(pets);
    } catch (error) {
        console.error(error);
        response.status(500).json({ message: 'Erro ao buscar pets.', error });
    }
});

// [POST] Criar um novo pet
routes.post('/pets', async (request: Request, response: Response) => {
    const { tutorId, racaId, especie, dataEntrada, dataSaida } = request.body;

    try {
        const newPet = { tutorId, racaId, especie, dataEntrada, dataSaida };
        const insertedIds = await knex('Pet').insert(newPet);
        const petId = insertedIds[0];
        
         response.status(201).json({ id: petId, ...newPet });
    } catch (error) {
        console.error(error);
         response.status(500).json({ message: 'Erro ao criar pet.', error });
    }
});

// [PUT] Atualizar um pet
routes.put('/pets/:id', async (request: Request, response: Response) => {
    const { id } = request.params;
    const { tutorId, racaId, especie, dataEntrada, dataSaida } = request.body;

    try {
        const updatedCount = await knex('Pet')
            .where('id', id)
            .update({ tutorId, racaId, especie, dataEntrada, dataSaida });

        if (updatedCount === 0) {
             response.status(404).json({ message: 'Pet não encontrado.' });
        }

         response.json({ message: 'Pet atualizado com sucesso.' });
    } catch (error) {
        console.error(error);
         response.status(500).json({ message: 'Erro ao atualizar pet.', error });
    }
});

// [DELETE] Deletar um pet
routes.delete('/pets/:id', async (request: Request, response: Response) => {
    const { id } = request.params;

    try {
        const deletedCount = await knex('Pet').where('id', id).del();

        if (deletedCount === 0) {
             response.status(404).json({ message: 'Pet não encontrado.' });
        }

         response.status(204).send();
    } catch (error) {
        console.error(error);
         response.status(500).json({ message: 'Erro ao deletar pet.', error });
    }
});

export default routes;
